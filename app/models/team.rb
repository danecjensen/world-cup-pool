class Team < ApplicationRecord
  belongs_to :group, optional: true
  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  scope :alphabetical, -> { order(:name) }
end
