class User < ApplicationRecord
  attr_accessor :remember_token
  has_secure_password

  validates :email, length: {maximum: Settings.email_max_length}
  validates :email, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i}
  validates :email, presence: true
  validates :name, length: {maximum: Settings.name_max_length}
  validates :name, presence: true
  validates :password, presence: true,
                      length: {maximum: Settings.password_max_length},
                      allow_nil: true

  before_save :downcase_email

  class << self
    def User.digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def User.new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated? remember_token
    return false unless remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase!
  end
end
