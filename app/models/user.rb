class User < ApplicationRecord
  before_save :downcase_email
  VALID_EMAIL_REGEX = [/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i].freeze
  validates :email, presence: true,
  length: {maximum: Settings.email_max_length},
  format: {with: VALID_EMAIL_REGEX}

  private

  def downcase_email
    email.downcase!
  end
  has_secure_password
end
