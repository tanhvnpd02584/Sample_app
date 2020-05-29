class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :microposts, dependent: :destroy
  has_secure_password
  has_many :active_relationships, class_name: "Relationship",
   foreign_key: "follower_id",
   dependent: :destroy
  has_many :passive_relationships,
   class_name: "Relationship",
    foreign_key: "followed_id",
   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

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

  def display_image
    image.variant(resize_to_limit: [500, 500])
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

  # update reset_digest encrypt and reset_sent_at time now
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
    reset_sent_at: Time.zone.now
  end

  # send password da reset den email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Return true if reset_sent_at < 2 hours
  def password_reset_expired?
    reset_sent_at < Settings.time_enpired.hours.ago
  end

  # Find microposts by user
  def feed
    microposts
  end

  # Find all microposts
  def feed_all
    Micropost.feed_user(following_ids, id)
  end

  # add 1 fowllow in 1 user
  def follow other_user
    following << other_user
  end

  # delete folow from relation base on user
  def unfollow other_user
    following.delete(other_user)
  end

  # return true if the current user is following the user
  def following? other_user
    following.include?(other_user)
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
