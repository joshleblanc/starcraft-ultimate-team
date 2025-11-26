class Pack < ApplicationRecord
  PACK_TYPES = %w[standard premium legendary].freeze

  has_many :pack_openings, dependent: :destroy

  validates :name, presence: true
  validates :pack_type, presence: true, inclusion: { in: PACK_TYPES }
  validates :card_count, numericality: { greater_than: 0 }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
  validates :common_weight, :rare_weight, :epic_weight, :legendary_weight,
            numericality: { greater_than_or_equal_to: 0 }

  def total_weight
    common_weight + rare_weight + epic_weight + legendary_weight
  end

  def rarity_probabilities
    total = total_weight.to_f
    {
      common: (common_weight / total * 100).round(1),
      rare: (rare_weight / total * 100).round(1),
      epic: (epic_weight / total * 100).round(1),
      legendary: (legendary_weight / total * 100).round(1)
    }
  end

  def open_for(user)
    return nil unless user.credits >= cost

    user.with_lock do
      user.update!(credits: user.credits - cost)
      
      opening = pack_openings.create!(user: user, opened_at: Time.current)
      cards = generate_cards
      
      user_cards = cards.map do |card|
        user.user_cards.create!(card: card)
      end

      { opening: opening, cards: user_cards }
    end
  end

  private

  def generate_cards
    card_count.times.map { pick_random_card }
  end

  def pick_random_card
    rarity = weighted_random_rarity
    Card.players.by_rarity(rarity).order("RANDOM()").first || Card.players.order("RANDOM()").first
  end

  def weighted_random_rarity
    roll = rand(total_weight)
    cumulative = 0

    [
      ["common", common_weight],
      ["rare", rare_weight],
      ["epic", epic_weight],
      ["legendary", legendary_weight]
    ].each do |rarity, weight|
      cumulative += weight
      return rarity if roll < cumulative
    end

    "common"
  end
end
