class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :picks, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :display_name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 2..30 }

  scope :admins, -> { where(admin: true) }

  def admin?
    admin
  end

  def total_points
    picks.sum(:points_awarded)
  end
end
