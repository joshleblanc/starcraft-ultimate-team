class ExchangeRedemption < ApplicationRecord
  belongs_to :set_exchange
  belongs_to :exchange_slot
  belongs_to :user_card
  belongs_to :output_user_card, class_name: "UserCard"

  validates :set_exchange_id, :exchange_slot_id, :user_card_id, :output_user_card_id, presence: true
  validates :user_card_id, uniqueness: true
end
