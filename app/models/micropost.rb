class Micropost < ApplicationRecord
  # relationships
  belongs_to :user
  has_one_attached :image

  scope :by_created_at, ->{order(created_at: :desc)}
  scope :feed_user, ->(id){where "user_id = ?", "#{id}"}

  # validates
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.size_content}
  validates :image, content_type: {in: Settings.file_valid,
   message: I18n.t("microposts.text_micropost_error_image_file_name")},
    size: {less_than: 5.megabytes,
     message: I18n.t("microposts.text_micropost_error_image_file_size")}

  # return image resize 500 500
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end
