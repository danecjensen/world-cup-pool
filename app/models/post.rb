class Post < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: "User", optional: true

  has_one_attached :media
  has_many :comments, dependent: :destroy

  # A post is one of:
  #   media     - an uploaded photo or video (the original behaviour)
  #   link      - any external URL, shown as a rich Open Graph preview card
  #   instagram - an Instagram post/reel, shown via Instagram's embed
  #   threads   - a Threads post, shown via the Threads embed
  POST_TYPES = %w[media link instagram threads].freeze
  EMBED_TYPES = %w[instagram threads].freeze
  LINK_BASED_TYPES = %w[link instagram threads].freeze

  validates :caption, length: { maximum: 500 }
  validates :post_type, inclusion: { in: POST_TYPES }
  validate :media_must_be_attached
  validate :media_type_and_size
  validate :link_url_present_and_valid

  before_validation :normalize_link_url
  before_save :fetch_open_graph_metadata, if: :should_fetch_open_graph?

  scope :newest_first, -> { order(created_at: :desc) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :pending, -> { where(approved_at: nil) }

  ALLOWED_CONTENT_TYPES = %w[
    image/png image/jpeg image/jpg image/gif image/webp
    video/mp4 video/quicktime video/webm video/ogg
  ].freeze

  MAX_FILE_SIZE = 100.megabytes

  # Recognised permalink shapes for the two embed providers.
  INSTAGRAM_HOSTS = %w[instagram.com www.instagram.com m.instagram.com].freeze
  INSTAGRAM_PATH = %r{\A/(p|reel|tv)/([A-Za-z0-9_-]+)/?\z}
  THREADS_HOSTS = %w[threads.net www.threads.net threads.com www.threads.com].freeze
  THREADS_PATH = %r{\A/@[^/]+/post/[A-Za-z0-9_-]+/?\z}

  def approved?
    approved_at.present?
  end

  def pending?
    !approved?
  end

  # Mark the post as approved by an admin so it becomes visible in the feed.
  def approve!(by:)
    update!(approved_at: Time.current, approved_by: by)
  end

  def media?
    post_type == "media"
  end

  def link?
    post_type == "link"
  end

  def instagram?
    post_type == "instagram"
  end

  def threads?
    post_type == "threads"
  end

  def embed?
    EMBED_TYPES.include?(post_type)
  end

  def link_based?
    LINK_BASED_TYPES.include?(post_type)
  end

  def image?
    media.attached? && media.content_type.to_s.start_with?("image/")
  end

  def video?
    media.attached? && media.content_type.to_s.start_with?("video/")
  end

  # The human-friendly host ("nytimes.com") used as a label on link cards.
  def link_host
    return og_site_name if og_site_name.present?
    return nil if link_url.blank?

    URI.parse(link_url).host&.sub(/\Awww\./, "")
  rescue URI::Error
    nil
  end

  private

  def media_must_be_attached
    return unless media?

    errors.add(:media, "must be a photo or video") unless media.attached?
  end

  def media_type_and_size
    return unless media?
    return unless media.attached?

    unless ALLOWED_CONTENT_TYPES.include?(media.content_type)
      errors.add(:media, "must be a photo (PNG, JPG, GIF, WEBP) or video (MP4, MOV, WEBM, OGG)")
    end

    if media.byte_size > MAX_FILE_SIZE
      errors.add(:media, "must be smaller than #{MAX_FILE_SIZE / 1.megabyte} MB")
    end
  end

  def link_url_present_and_valid
    return unless link_based?

    if link_url.blank?
      errors.add(:link_url, "can't be blank")
      return
    end

    case post_type
    when "link"
      errors.add(:link_url, "must be a valid http(s) URL") unless valid_http_url?(link_url)
    when "instagram"
      errors.add(:link_url, "must be an Instagram post, reel or TV link") unless instagram_url?(link_url)
    when "threads"
      errors.add(:link_url, "must be a Threads post link") unless threads_url?(link_url)
    end
  end

  def normalize_link_url
    return unless link_based?
    return if link_url.blank?

    self.link_url = link_url.strip

    case post_type
    when "instagram"
      normalized = normalize_instagram_url(link_url)
      self.link_url = normalized if normalized
    when "threads"
      normalized = normalize_threads_url(link_url)
      self.link_url = normalized if normalized
    end
  end

  def valid_http_url?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::Error
    false
  end

  def instagram_url?(value)
    uri = parse_http_uri(value)
    return false unless uri

    INSTAGRAM_HOSTS.include?(uri.host.downcase) && uri.path.to_s.match?(INSTAGRAM_PATH)
  end

  def threads_url?(value)
    uri = parse_http_uri(value)
    return false unless uri

    THREADS_HOSTS.include?(uri.host.downcase) && uri.path.to_s.match?(THREADS_PATH)
  end

  def parse_http_uri(value)
    uri = URI.parse(value)
    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri
  rescue URI::Error
    nil
  end

  # Strip tracking params/fragments and canonicalise to a clean permalink the
  # Instagram embed script understands.
  def normalize_instagram_url(value)
    uri = parse_http_uri(value)
    return nil unless uri && INSTAGRAM_HOSTS.include?(uri.host.downcase)

    match = uri.path.to_s.match(INSTAGRAM_PATH)
    return nil unless match

    "https://www.instagram.com/#{match[1]}/#{match[2]}/"
  end

  def normalize_threads_url(value)
    uri = parse_http_uri(value)
    return nil unless uri && THREADS_HOSTS.include?(uri.host.downcase)
    return nil unless uri.path.to_s.match?(THREADS_PATH)

    host = uri.host.downcase.sub(/\Awww\./, "")
    "https://#{host}#{uri.path.chomp('/')}"
  end

  def should_fetch_open_graph?
    link_based? && link_url.present? && (new_record? || will_save_change_to_link_url?)
  end

  # Populate the Open Graph fields from the linked page. Used for the rich
  # preview on link posts, and as a graceful fallback (image/description) for
  # embeds when the provider's embed script is blocked.
  def fetch_open_graph_metadata
    result = OpenGraphFetcher.fetch(link_url)

    self.og_title = result.title
    self.og_description = result.description
    self.og_image_url = result.image
    self.og_site_name = result.site_name
  end
end
