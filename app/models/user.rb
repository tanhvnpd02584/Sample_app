class User < ApplicationRecord
  has_secure_password

  validates :email, length: {maximum: Settings.email_max_length}
  validates :email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}
  validates :email, presence: true
  validates :name, length: {maximum: Settings.name_max_length}
  validates :name, presence: true
  validates :password, length: {maximum: Settings.password_max_length}
  validates :password, presence: true

  before_save :downcase_email

  private

  def downcase_email
    email.downcase!
  end
end
