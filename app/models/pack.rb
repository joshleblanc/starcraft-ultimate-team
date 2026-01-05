class Pack < ApplicationRecord
  PACK_TYPES = %w[standard premium].freeze

  has_many :pack_openings, dependent: :destroy

  validates :name, presence: true
  validates :pack_type, presence: true, inclusion: { in: PACK_TYPES }
  validates :card_count, numericality: { greater_than: 0 }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
  validates :bronze_weight, :silver_weight, :gold_weight, :diamond_weight, :master_weight, :legend_weight,
            numericality: { greater_than_or_equal_to: 0 }

  RATING_RANGES = {
    bronze: 50..64,
    silver: 65..74,
    gold: 75..84,
    diamond: 85..92,
    master: 93..96,
    legend: 97..100
  }.freeze

  def total_weight
    bronze_weight + silver_weight + gold_weight + diamond_weight + master_weight + legend_weight
  end

  def rating_probabilities
    total = total_weight.to_f
    {
      bronze: (bronze_weight / total * 100).round(1),
      silver: (silver_weight / total * 100).round(1),
      gold: (gold_weight / total * 100).round(1),
      diamond: (diamond_weight / total * 100).round(1),
      master: (master_weight / total * 100).round(1),
      legend: (legend_weight / total * 100).round(1)
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
    tier = weighted_random_tier
    range = RATING_RANGES[tier.to_sym]
    Card.players.in_rating_range(range.min, range.max).order("RANDOM()").first || Card.players.order("RANDOM()").first
  end

  def weighted_random_tier
    roll = rand(total_weight)
    cumulative = 0

    [
      [ "bronze", bronze_weight ],
      [ "silver", silver_weight ],
      [ "gold", gold_weight ],
      [ "diamond", diamond_weight ],
      [ "master", master_weight ],
      [ "legend", legend_weight ]
    ].each do |tier, weight|
      cumulative += weight
      return tier if roll < cumulative
    end

    "bronze"
  end
end
