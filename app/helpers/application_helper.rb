module ApplicationHelper
  def pool_name
    ENV.fetch("POOL_NAME", "World Cup 2026 Pool")
  end

  def pool_tagline
    ENV.fetch("POOL_TAGLINE", "2026 FIFA World Cup Pool · single shared pool · open registration")
  end
end
