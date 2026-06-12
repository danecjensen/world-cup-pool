class Post < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: "User", optional: true

  has_one_attached :media
  has_many :comments, dependent: :destroy

  validates :caption, length: { maximum: 500 }
  validate :media_must_be_attached
  validate :media_type_and_size

  scope :newest_first, -> { order(created_at: :desc) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :pending, -> { where(approved_at: nil) }

  ALLOWED_CONTENT_TYPES = %w[
    image/png image/jpeg image/jpg image/gif image/webp
    video/mp4 video/quicktime video/webm video/ogg
  ].freeze

  MAX_FILE_SIZE = 100.megabytes

  def approved?
    approved_at.present?
  end

  def pending?
    !approved?
  end

  # Mark the post as approved by an admin so it becomes visible in the feed.
  def approve!(by:)
    update!(approved_at: Time.current, approved_by: by)
  end

  def image?
    media.attached? && media.content_type.to_s.start_with?("image/")
  end

  def video?
    media.attached? && media.content_type.to_s.start_with?("video/")
  end

  private

  def media_must_be_attached
    errors.add(:media, "must be a photo or video") unless media.attached?
  end

  def media_type_and_size
    return unless media.attached?

    unless ALLOWED_CONTENT_TYPES.include?(media.content_type)
      errors.add(:media, "must be a photo (PNG, JPG, GIF, WEBP) or video (MP4, MOV, WEBM, OGG)")
    end

    if media.byte_size > MAX_FILE_SIZE
      errors.add(:media, "must be smaller than #{MAX_FILE_SIZE / 1.megabyte} MB")
    end
  end
end
