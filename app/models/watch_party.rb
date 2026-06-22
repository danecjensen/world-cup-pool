class WatchParty < ApplicationRecord
  belongs_to :user
  belongs_to :match, optional: true

  # How long a watch party update stays advertised on the home page. After this
  # window it's assumed the game (and the meet-up) is over.
  ACTIVE_WINDOW = 6.hours

  validates :location, presence: true, length: { maximum: 120 }
  validates :match_label, length: { maximum: 120 }
  validate :game_must_be_present

  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(created_at: ACTIVE_WINDOW.ago..).newest_first }

  # The active watch parties, keeping only the most recent update per user so a
  # single person changing their mind doesn't flood the home page.
  def self.active_latest_per_user
    active.includes(:user, match: [:home_team, :away_team]).to_a.uniq(&:user_id)
  end

  # The human-friendly name of the game being watched, e.g.
  # "🇳🇴 Norway vs Senegal 🇸🇳" when a fixture is selected, otherwise whatever
  # free-text label the user typed.
  def game_name
    if match
      "#{match.home_team.flag_emoji} #{match.home_team.name} vs #{match.away_team.name} #{match.away_team.flag_emoji}".strip
    else
      match_label
    end
  end

  private

  def game_must_be_present
    return if match.present? || match_label.present?

    errors.add(:match_label, "can't be blank — pick a game or describe it")
  end
end
