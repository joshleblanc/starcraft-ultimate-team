class LineupSlot < ApplicationRecord
  belongs_to :lineup
  belongs_to :user_card

  validates :position, presence: true, numericality: { in: 1..5 }
  validates :position, uniqueness: { scope: :lineup_id }
  validates :user_card_id, uniqueness: { scope: :lineup_id, message: "is already in this lineup" }

  delegate :name, :race, :overall_rating, :rarity, :card, to: :user_card
end
