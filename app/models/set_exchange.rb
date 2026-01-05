class SetExchange < ApplicationRecord
  belongs_to :card_set

  has_many :exchange_redemptions, dependent: :destroy

  validates :name, presence: true
  validates :input_min_rating, :input_max_rating, :input_count, :output_min_rating, :output_max_rating, presence: true
  validates :input_min_rating, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 100 }
  validates :input_max_rating, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 100 }
  validates :output_min_rating, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 100 }
  validates :output_max_rating, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 100 }
  validates :input_count, numericality: { greater_than: 0 }
  validates :output_count, numericality: { greater_than: 0 }
  validate :input_rating_range_valid
  validate :output_rating_range_valid

  scope :active, -> { where(active: true) }
  scope :for_card_set, ->(set_id) { where(card_set_id: set_id) }

  def input_rating_range
    input_min_rating..input_max_rating
  end

  def output_rating_range
    output_min_rating..output_max_rating
  end

  def input_rating_range=(range)
    self.input_min_rating = range.begin
    self.input_max_rating = range.end
  end

  def output_rating_range=(range)
    self.output_min_rating = range.begin
    self.output_max_rating = range.end
  end

  def exchange_description
    "Exchange #{input_count} #{input_min_rating}-#{input_max_rating} rated cards for #{output_count} #{output_min_rating}-#{output_max_rating} rated card"
  end

  def can_redeem?(user_cards)
    eligible_cards = eligible_cards_for_user(user_cards.first&.user)
    eligible_cards.count >= input_count
  end

  def eligible_cards_for_user(user)
    user.user_cards.joins(:card)
        .where(card_set_id: card_set_id)
        .where(cards: { overall_rating: input_min_rating..input_max_rating })
        .where.not(id: exchange_redemptions.select(:user_card_id))
  end

  def available_exchange_count(user)
    eligible_cards = eligible_cards_for_user(user)
    (eligible_cards.count / input_count.to_f).floor
  end

  def redeem_for!(user)
    return false unless active?

    eligible_cards = eligible_cards_for_user(user)
    return false if eligible_cards.count < input_count

    ActiveRecord::Base.transaction do
      selected_cards = eligible_cards.limit(input_count)
      card_ids = selected_cards.pluck(:id)

      selected_cards.update_all(user_id: nil, team_id: nil)

      output_card = Card.players.by_card_set(card_set_id)
                        .in_rating_range(output_min_rating, output_max_rating)
                        .order("RANDOM()")
                        .first

      return false unless output_card

      output_user_card = user.user_cards.create!(card: output_card)

      card_ids.each do |card_id|
        exchange_redemptions.create!(user_card_id: card_id, output_user_card_id: output_user_card.id)
      end

      output_user_card
    end
  end

  private

  def input_rating_range_valid
    return if input_min_rating.nil? || input_max_rating.nil?
    return if input_min_rating <= input_max_rating

    errors.add(:base, "Input min rating must be less than or equal to max rating")
  end

  def output_rating_range_valid
    return if output_min_rating.nil? || output_max_rating.nil?
    return if output_min_rating <= output_max_rating

    errors.add(:base, "Output min rating must be less than or equal to max rating")
  end
end
