# Converts a free-text nation name into a flag emoji.
#
# The user types the name of the nation they support (e.g. "Brazil", "USA",
# "South Korea") and we look up the ISO 3166-1 alpha-2 country code, then turn
# that code into the corresponding regional-indicator flag emoji (🇧🇷, 🇺🇸 …).
module NationFlag
  module_function

  # Returns the flag emoji for the given nation name, or nil if we can't
  # recognise it.
  def for(name)
    return nil if name.blank?

    code = ISO_CODES[normalize(name)]
    code && emoji_for(code)
  end

  # Normalises user input so "  São Tomé ", "sao tome" and "Sao Tome" all match.
  def normalize(name)
    name.to_s.strip.downcase
      .unicode_normalize(:nfkd)
      .gsub(/[^a-z0-9 ]/, "")
      .squeeze(" ")
      .strip
  end

  # Turns a country code into its flag emoji. Plain two-letter codes map each
  # letter to its regional indicator symbol (A => 🇦, …); the home nations use
  # special tag sequences instead.
  def emoji_for(code)
    return SUBDIVISION_FLAGS[code] if SUBDIVISION_FLAGS.key?(code)
    return nil if code.include?("-") # e.g. Northern Ireland has no emoji flag

    code.upcase.each_char.map { |c| [c.ord + 0x1F1A5].pack("U") }.join
  end

  # Common nation names (and aliases) mapped to their ISO 3166-1 alpha-2 code.
  ISO_CODES = {
    "afghanistan" => "AF", "albania" => "AL", "algeria" => "DZ", "andorra" => "AD",
    "angola" => "AO", "argentina" => "AR", "armenia" => "AM", "australia" => "AU",
    "austria" => "AT", "azerbaijan" => "AZ", "bahamas" => "BS", "bahrain" => "BH",
    "bangladesh" => "BD", "barbados" => "BB", "belarus" => "BY", "belgium" => "BE",
    "belize" => "BZ", "benin" => "BJ", "bhutan" => "BT", "bolivia" => "BO",
    "bosnia" => "BA", "bosnia and herzegovina" => "BA", "botswana" => "BW",
    "brazil" => "BR", "brunei" => "BN", "bulgaria" => "BG", "burkina faso" => "BF",
    "burundi" => "BI", "cambodia" => "KH", "cameroon" => "CM", "canada" => "CA",
    "cape verde" => "CV", "cabo verde" => "CV", "chad" => "TD", "chile" => "CL",
    "china" => "CN", "colombia" => "CO", "comoros" => "KM", "congo" => "CG",
    "costa rica" => "CR", "croatia" => "HR", "cuba" => "CU", "curacao" => "CW",
    "cyprus" => "CY", "czech republic" => "CZ", "czechia" => "CZ",
    "democratic republic of the congo" => "CD", "dr congo" => "CD",
    "denmark" => "DK", "djibouti" => "DJ", "dominica" => "DM",
    "dominican republic" => "DO", "ecuador" => "EC", "egypt" => "EG",
    "el salvador" => "SV", "england" => "GB-ENG", "equatorial guinea" => "GQ",
    "eritrea" => "ER", "estonia" => "EE", "eswatini" => "SZ", "swaziland" => "SZ",
    "ethiopia" => "ET", "fiji" => "FJ", "finland" => "FI", "france" => "FR",
    "gabon" => "GA", "gambia" => "GM", "georgia" => "GE", "germany" => "DE",
    "ghana" => "GH", "greece" => "GR", "grenada" => "GD", "guatemala" => "GT",
    "guinea" => "GN", "guinea bissau" => "GW", "guyana" => "GY", "haiti" => "HT",
    "honduras" => "HN", "hong kong" => "HK", "hungary" => "HU", "iceland" => "IS",
    "india" => "IN", "indonesia" => "ID", "iran" => "IR", "iraq" => "IQ",
    "ireland" => "IE", "israel" => "IL", "italy" => "IT", "ivory coast" => "CI",
    "cote divoire" => "CI", "jamaica" => "JM", "japan" => "JP", "jordan" => "JO",
    "kazakhstan" => "KZ", "kenya" => "KE", "kosovo" => "XK", "kuwait" => "KW",
    "kyrgyzstan" => "KG", "laos" => "LA", "latvia" => "LV", "lebanon" => "LB",
    "lesotho" => "LS", "liberia" => "LR", "libya" => "LY", "liechtenstein" => "LI",
    "lithuania" => "LT", "luxembourg" => "LU", "madagascar" => "MG",
    "malawi" => "MW", "malaysia" => "MY", "maldives" => "MV", "mali" => "ML",
    "malta" => "MT", "mauritania" => "MR", "mauritius" => "MU", "mexico" => "MX",
    "moldova" => "MD", "monaco" => "MC", "mongolia" => "MN", "montenegro" => "ME",
    "morocco" => "MA", "mozambique" => "MZ", "myanmar" => "MM", "namibia" => "NA",
    "nepal" => "NP", "netherlands" => "NL", "holland" => "NL",
    "new zealand" => "NZ", "nicaragua" => "NI", "niger" => "NE", "nigeria" => "NG",
    "north korea" => "KP", "north macedonia" => "MK", "macedonia" => "MK",
    "northern ireland" => "GB-NIR", "norway" => "NO", "oman" => "OM",
    "pakistan" => "PK", "palestine" => "PS", "panama" => "PA",
    "papua new guinea" => "PG", "paraguay" => "PY", "peru" => "PE",
    "philippines" => "PH", "poland" => "PL", "portugal" => "PT",
    "puerto rico" => "PR", "qatar" => "QA", "romania" => "RO", "russia" => "RU",
    "rwanda" => "RW", "saudi arabia" => "SA", "scotland" => "GB-SCT",
    "senegal" => "SN", "serbia" => "RS", "sierra leone" => "SL",
    "singapore" => "SG", "slovakia" => "SK", "slovenia" => "SI",
    "somalia" => "SO", "south africa" => "ZA", "south korea" => "KR",
    "korea" => "KR", "korea republic" => "KR", "south sudan" => "SS",
    "spain" => "ES", "sri lanka" => "LK", "sudan" => "SD", "suriname" => "SR",
    "sweden" => "SE", "switzerland" => "CH", "syria" => "SY", "taiwan" => "TW",
    "tajikistan" => "TJ", "tanzania" => "TZ", "thailand" => "TH", "togo" => "TG",
    "trinidad and tobago" => "TT", "trinidad" => "TT", "tunisia" => "TN",
    "turkey" => "TR", "turkiye" => "TR", "turkmenistan" => "TM", "uganda" => "UG",
    "ukraine" => "UA", "united arab emirates" => "AE", "uae" => "AE",
    "united kingdom" => "GB", "uk" => "GB", "great britain" => "GB",
    "britain" => "GB", "united states" => "US", "united states of america" => "US",
    "usa" => "US", "us" => "US", "america" => "US", "uruguay" => "UY",
    "uzbekistan" => "UZ", "venezuela" => "VE", "vietnam" => "VN", "wales" => "GB-WLS",
    "yemen" => "YE", "zambia" => "ZM", "zimbabwe" => "ZW"
  }.freeze

  # The home nations have their own flag emoji built from special tag sequences
  # rather than a pair of regional indicators.
  SUBDIVISION_FLAGS = {
    "GB-ENG" => "🏴\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}",
    "GB-SCT" => "🏴\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}",
    "GB-WLS" => "🏴\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}"
  }.freeze
end
