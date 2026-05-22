class Group < ApplicationRecord
  has_many :teams
  has_many :matches

  validates :letter, presence: true, uniqueness: true
end
