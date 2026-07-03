# One World Cup shirt design, backed by an image in public/img and rated
# via head-to-head Elo from Drip Cup votes.
class Kit < ApplicationRecord
  STARTING_RATING = 1000.0
  IMAGE_DIR = "img".freeze
  IMAGE_EXTENSIONS = /\.(jpe?g|png|webp)\z/i

  # Filenames that don't follow the "<team>-<home|away>[-<brand>]_<hash>" pattern.
  SPECIAL_NAMES = {
    "Screenshot-2026-05-28-095152" => "Argentina Away",
    "Screenshot-2026-05-28-095225" => "Argentina Home",
    "Screenshot-2026-05-28-095519" => "Belgium Away",
    "Screenshot-2026-05-28-095528" => "Belgium Home"
  }.freeze

  TOKEN_FIXES = { "us" => "USA", "usa" => "USA", "colombi" => "Colombia" }.freeze
  BRAND_TOKENS = %w[adidas kappa kelme majid nike puma].freeze
  NOISE_TOKENS = %w[kit 2026].freeze

  has_many :won_votes, class_name: "KitVote", foreign_key: :winner_kit_id, dependent: :destroy, inverse_of: :winner_kit
  has_many :lost_votes, class_name: "KitVote", foreign_key: :loser_kit_id, dependent: :destroy, inverse_of: :loser_kit

  validates :name, presence: true
  validates :image_path, presence: true, uniqueness: true

  scope :ranked, -> { order(rating: :desc, wins: :desc, name: :asc) }

  # Registers any image dropped into public/img as a kit. Already-registered
  # images are untouched, so ratings survive re-syncs.
  def self.sync_from_images!
    dir = Rails.public_path.join(IMAGE_DIR)
    return unless dir.directory?

    existing = pluck(:image_path).to_set
    dir.children.sort.each do |file|
      next unless file.basename.to_s.match?(IMAGE_EXTENSIONS)

      path = "/#{IMAGE_DIR}/#{file.basename}"
      next if existing.include?(path)

      create!(name: name_from_filename(file.basename.to_s), image_path: path)
    end
  end

  def self.random_pair
    order(Arel.sql("RANDOM()")).limit(2).to_a
  end

  def self.name_from_filename(filename)
    stem = File.basename(filename, ".*").sub(/_[0-9a-f]{6,}\z/i, "")
    return SPECIAL_NAMES[stem] if SPECIAL_NAMES.key?(stem)

    tokens = stem.downcase.split("-") - NOISE_TOKENS
    brands = tokens & BRAND_TOKENS
    name = (tokens - brands).map { |t| TOKEN_FIXES.fetch(t, t.capitalize) }.join(" ")
    name << " (#{brands.map(&:capitalize).join(' ')})" if brands.any?
    name
  end

  def duel_count
    wins + losses
  end
end
