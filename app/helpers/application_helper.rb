module ApplicationHelper
  def pool_name
    ENV.fetch("POOL_NAME", "World Cup 2026 Pool")
  end

  def pool_tagline
    ENV.fetch("POOL_TAGLINE", "2026 FIFA World Cup Pool · single shared pool · open registration")
  end

  # Whether the signed-in user may delete the given post/comment — true for the
  # author and for any admin (so admins can moderate the feed).
  def can_moderate?(record)
    return false unless user_signed_in?
    record.user_id == current_user.id || current_user.admin?
  end

  # Host city for each 2026 World Cup stadium, so matches can show where the
  # venue is located alongside the venue name.
  VENUE_CITIES = {
    "MetLife Stadium"        => "New York/New Jersey",
    "SoFi Stadium"           => "Los Angeles",
    "AT&T Stadium"           => "Dallas",
    "Mercedes-Benz Stadium"  => "Atlanta",
    "Hard Rock Stadium"      => "Miami",
    "NRG Stadium"            => "Houston",
    "Estadio Azteca"         => "Mexico City",
    "Estadio Akron"          => "Guadalajara",
    "BMO Field"              => "Toronto",
    "BC Place"               => "Vancouver",
    "Levi's Stadium"         => "San Francisco Bay Area",
    "Lincoln Financial Field" => "Philadelphia",
    "Lumen Field"            => "Seattle",
    "Gillette Stadium"       => "Boston",
    "Arrowhead Stadium"      => "Kansas City",
    "Estadio BBVA"           => "Monterrey"
  }.freeze

  # The host city for a venue, or nil if the venue isn't recognized.
  def venue_location(venue)
    VENUE_CITIES[venue]
  end

  # "Venue — City" when the city is known, otherwise just the venue name.
  def venue_with_location(venue)
    return if venue.blank?
    city = venue_location(venue)
    city ? "#{venue} — #{city}" : venue
  end
end
