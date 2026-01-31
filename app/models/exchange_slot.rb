class ExchangeSlot < ApplicationRecord
  belongs_to :set_exchange
  has_many :exchange_qualifications, dependent: :destroy

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :position, uniqueness: { scope: :set_exchange_id }

  QUALIFICATION_TYPES = %w[rating_range specific_card specific_set].freeze

  def required_cards_description
    qualifications = exchange_qualifications.to_a
    return "No requirements" if qualifications.empty?

    parts = qualifications.map do |q|
      case q.qualification_type
      when "rating_range"
        "rating #{q.min_rating}-#{q.max_rating}"
      when "specific_card"
        q.card.name
      when "specific_set"
        q.card_set.name
      end
    end

    parts.join(" OR ")
  end

  def eligible_cards_for_user(user)
    qualifiers = exchange_qualifications.to_a
    return user_cards.none if qualifiers.empty?

    user_cards = user.user_cards.joins(:card)

    qualifiers.reduce(nil) do |scope, qualification|
      card_scope = case qualification.qualification_type
      when "rating_range"
                     user_cards.where(cards: { overall_rating: qualification.min_rating..qualification.max_rating })
      when "specific_card"
                     user_cards.where(card_id: qualification.card_id)
      when "specific_set"
                     user_cards.where(cards: { card_set_id: qualification.card_set_id })
      end

       if scope.nil?
         card_scope
       else
         scope.or(card_scope)
       end
    end || user_cards.none
  end
end
