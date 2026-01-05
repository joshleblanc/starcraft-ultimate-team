class CardSet < ApplicationRecord
  has_many :cards, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  def card_count
    cards.count
  end

  def average_rating
    cards.average(:overall_rating)&.round || 0
  end
end
