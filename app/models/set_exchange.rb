class SetExchange < ApplicationRecord
  belongs_to :card_set
  has_many :exchange_slots, dependent: :destroy
  has_many :exchange_qualifications, through: :exchange_slots
  has_many :exchange_redemptions, dependent: :destroy

  validates :name, presence: true
  validates :output_min_rating, :output_max_rating, presence: true
  validates :output_count, numericality: { greater_than: 0 }
  validate :output_rating_range_valid

  scope :active, -> { where(active: true) }
  scope :for_card_set, ->(set_id) { where(card_set_id: set_id) }

  def output_rating_range
    output_min_rating..output_max_rating
  end

  def output_rating_range=(range)
    self.output_min_rating = range.begin
    self.output_max_rating = range.end
  end

  def exchange_description
    slots = exchange_slots.count
    "Complete #{slots} slot#{slots == 1 ? '' : 's'} for #{output_count} #{output_min_rating}-#{output_max_rating} rated card#{output_count == 1 ? '' : 's'}"
  end

  def can_redeem?(user)
    return false unless active?
    return false if exchange_slots.empty?

    exchange_slots.all? { |slot| slot.eligible_cards_for_user(user).exists? }
  end

  def eligible_cards_by_slot(user)
    exchange_slots.index_with { |slot| slot.eligible_cards_for_user(user) }
  end

  def available_exchange_count(user)
    eligible_by_slot = eligible_cards_by_slot(user)
    return 0 unless exchange_slots.all? { |slot| eligible_by_slot[slot].exists? }

    (exchange_slots.map { |slot| eligible_by_slot[slot].count }.min / 1.0).floor
  end

  def redeem_for!(user)
    return false unless active?
    return false unless can_redeem?(user)

    ActiveRecord::Base.transaction do
      slot_cards = {}

      exchange_slots.each do |slot|
        eligible_cards = slot.eligible_cards_for_user(user)
                            .where.not(id: exchange_redemptions.select(:user_card_id))
        selected_card = eligible_cards.first!
        slot_cards[slot] = selected_card

        selected_card.update!(user_id: nil, team_id: nil)
      end

      output_card = Card.players.by_card_set(card_set_id)
                        .where(overall_rating: output_min_rating..output_max_rating)
                        .order("RANDOM()")
                        .first

      return false unless output_card

      output_user_card = user.user_cards.create!(card: output_card)

      slot_cards.each do |slot, user_card|
        exchange_redemptions.create!(
          set_exchange: self,
          exchange_slot: slot,
          user_card: user_card,
          output_user_card: output_user_card
        )
      end

      output_user_card
    end
  end

  private

  def output_rating_range_valid
    return if output_min_rating.nil? || output_max_rating.nil?
    return if output_min_rating <= output_max_rating

    errors.add(:base, "Output min rating must be less than or equal to max rating")
  end
end
