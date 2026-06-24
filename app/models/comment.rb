class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :body, presence: true, length: { maximum: 500 }

  scope :oldest_first, -> { order(:created_at) }
end
