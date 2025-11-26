class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_cards, dependent: :destroy
  has_many :cards, through: :user_cards
  has_many :pack_openings, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Notification"

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :username, uniqueness: true, allow_nil: true, length: { minimum: 3, maximum: 20 }
  validates :credits, numericality: { greater_than_or_equal_to: 0 }

  def active_team
    teams.first
  end

  def starters
    user_cards.starters.includes(:card)
  end

  def bench
    user_cards.bench.includes(:card)
  end

  def can_afford?(amount)
    credits >= amount
  end

  def spend_credits!(amount)
    raise "Insufficient credits" unless can_afford?(amount)
    decrement!(:credits, amount)
  end

  def earn_credits!(amount)
    increment!(:credits, amount)
  end

  def unread_notifications_count
    notifications.where(read_at: nil).count
  end

  def display_name
    username.presence || email_address.split("@").first
  end
end
