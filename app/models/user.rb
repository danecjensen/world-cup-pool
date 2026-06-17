class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :picks, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :display_name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 2..30 }

  scope :admins, -> { where(admin: true) }

  def admin?
    admin
  end

  # The display name with the supported nation's flag appended, e.g. "Dane 🇺🇸".
  def name_with_flag
    [display_name, support_flag].compact_blank.join(" ")
  end

  def supports_nation?
    support_flag.present?
  end

  def total_points
    picks.sum(:points_awarded)
  end
end
