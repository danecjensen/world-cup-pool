# Fetches a remote URL and extracts Open Graph (and a few sensible fallback)
# metadata so a pasted link can be rendered as a rich preview card.
#
# It is deliberately conservative: short timeouts, a capped response body, a
# small redirect budget and http(s)-only, so a slow or hostile page can't tie
# up a request. Any failure simply returns an empty result — callers fall back
# to showing the bare link.
class OpenGraphFetcher
  Result = Struct.new(:title, :description, :image, :site_name, keyword_init: true) do
    def present?
      [title, description, image, site_name].any?(&:present?)
    end
  end

  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 5
  MAX_REDIRECTS = 3
  MAX_BYTES = 2.megabytes
  USER_AGENT = "Mozilla/5.0 (compatible; WorldCupPoolBot/1.0; +https://github.com/danecjensen/world-cup-pool)".freeze

  def self.fetch(url)
    new(url).fetch
  end

  def initialize(url)
    @url = url
  end

  def fetch
    html = get_body(@url)
    return Result.new unless html

    parse(html)
  rescue StandardError => e
    Rails.logger.info("[OpenGraphFetcher] failed for #{@url}: #{e.class}: #{e.message}")
    Result.new
  end

  private

  def get_body(url, redirects_left = MAX_REDIRECTS)
    uri = URI.parse(url)
    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.is_a?(URI::HTTPS)
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT
    request["Accept"] = "text/html,application/xhtml+xml"

    response = http.request(request)

    case response
    when Net::HTTPSuccess
      read_capped(response)
    when Net::HTTPRedirection
      return nil if redirects_left.zero?

      location = response["location"]
      return nil if location.blank?

      get_body(URI.join(url, location).to_s, redirects_left - 1)
    end
  end

  # Read at most MAX_BYTES so a giant page can't exhaust memory.
  def read_capped(response)
    body = response.body.to_s
    body.byteslice(0, MAX_BYTES)
  end

  def parse(html)
    doc = Nokogiri::HTML(html)

    Result.new(
      title: meta(doc, "og:title") || doc.at_css("title")&.text&.strip,
      description: meta(doc, "og:description") || meta_name(doc, "description"),
      image: absolute_image(meta(doc, "og:image") || meta(doc, "og:image:url")),
      site_name: meta(doc, "og:site_name")
    )
  end

  def meta(doc, property)
    value = doc.at_css("meta[property=\"#{property}\"]")&.[]("content")
    value.presence&.strip
  end

  def meta_name(doc, name)
    value = doc.at_css("meta[name=\"#{name}\"]")&.[]("content")
    value.presence&.strip
  end

  # Resolve protocol-relative or root-relative image URLs against the page URL.
  def absolute_image(image)
    return nil if image.blank?

    URI.join(@url, image).to_s
  rescue URI::Error
    image
  end
end
