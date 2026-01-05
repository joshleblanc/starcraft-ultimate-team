class ExchangeQualification < ApplicationRecord
  belongs_to :exchange_slot

  validates :qualification_type, presence: true, inclusion: { in: ExchangeSlot::QUALIFICATION_TYPES }

  validate :has_at_least_one_filter

  delegate :name, to: :card, prefix: true, allow_nil: true
  delegate :name, to: :card_set, prefix: true, allow_nil: true

  def card
    Card.find_by(id: card_id) if card_id.present?
  end

  def card_set
    CardSet.find_by(id: card_set_id) if card_set_id.present?
  end

  private

  def has_at_least_one_filter
    case qualification_type
    when "rating_range"
      errors.add(:base, "Rating range qualifications require min_rating") if min_rating.nil?
      errors.add(:base, "Rating range qualifications require max_rating") if max_rating.nil?
    when "specific_card"
      errors.add(:base, "Specific card qualifications require a card") if card_id.nil?
    when "specific_set"
      errors.add(:base, "Specific set qualifications require a card_set") if card_set_id.nil?
    end
  end
end
