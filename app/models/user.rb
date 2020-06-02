class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
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
  before_create :create_activation_digest

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

  # if the given digest true thi k Bcrypt con neu false thi thoi
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  # activation account
  def activate
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  # send activations email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
