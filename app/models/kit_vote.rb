# A single head-to-head Drip Cup pick. Recording a vote applies a standard
# Elo update (K = 32) to both kits atomically.
class KitVote < ApplicationRecord
  K_FACTOR = 32

  belongs_to :user
  belongs_to :winner_kit, class_name: "Kit"
  belongs_to :loser_kit, class_name: "Kit"

  validate :kits_must_differ

  def self.record!(user:, winner:, loser:)
    transaction do
      # Lock in a stable order so two concurrent votes on the same pair
      # can't deadlock.
      [winner, loser].sort_by(&:id).each(&:lock!)

      expected_win = 1.0 / (1 + 10**((loser.rating - winner.rating) / 400.0))
      delta = K_FACTOR * (1 - expected_win)

      winner.update!(rating: winner.rating + delta, wins: winner.wins + 1)
      loser.update!(rating: loser.rating - delta, losses: loser.losses + 1)
      create!(user: user, winner_kit: winner, loser_kit: loser)
    end
  end

  private

  def kits_must_differ
    errors.add(:loser_kit, "can't be the same as the winner") if winner_kit_id == loser_kit_id
  end
end
