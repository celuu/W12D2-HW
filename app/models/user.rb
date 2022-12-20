# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  has_secure_password

  # / / - show that its a regex pattern
  # [] - allow anything that is inside them
  # a-z - all lowercase letters
  # A-Z - all capital letters
  # 0-9 - all digits
  # example) validates :username, length: { in: 3..30 }, format: { with: /[a-zA-Z_-0-9]/, message: "can't be an email" }

  validates :username, :email, :session_token, presence: true, uniqueness: true
  validates :username, length: { in: 3..30 }format: { without: URI::MailTo::EMAIL_REGEXP, message:  "can't be an email" }
  validates :email, length: { in: 3..255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 6..255 }, allow_nil: true

  before_validation :ensure_session_token

  # taking in a username and a password
  # from our user model, we can do active record queries
  # given a username, find a user
  # User.find_by(key: value)
  def self.find_by_credentials(username, password)
    @user = User.find_by(username: username)
    if @user && @user.is_password?(password) 
      return @user
    else
      return nil
    end
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def reset_session_token
    self.session_token = generate_unique_session_token
    self.save!
    self.session_token
  end

  private
  def generate_unique_session_token
    token = SecureRandom::urlsafe_base64
    while User.exists?
      token = SecureRandom::urlsafe_base64
    end
    token
  end

  def ensure_session_token
    self.session_token ||= generate_unique_session_token
  end
  
end