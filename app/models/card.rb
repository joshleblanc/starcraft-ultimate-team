class Card < ApplicationRecord
  RACES = %w[Terran Zerg Protoss Random].freeze
  RARITIES = %w[common rare epic legendary].freeze
  ROLES = %w[player coach].freeze

  has_many :user_cards, dependent: :destroy
  has_many :users, through: :user_cards

  validates :name, presence: true
  validates :race, presence: true, inclusion: { in: RACES }
  validates :rarity, presence: true, inclusion: { in: RARITIES }
  validates :player_role, inclusion: { in: ROLES }
  
  validates :macro, :micro, :starsense, :poise, :speed,
            numericality: { in: 1..100 }
  validates :early_game, :mid_game, :late_game,
            numericality: { in: -30..30 }

  scope :by_rarity, ->(rarity) { where(rarity: rarity) }
  scope :by_race, ->(race) { where(race: race) }
  scope :players, -> { where(player_role: "player") }

  before_save :calculate_overall_rating

  def calculate_overall_rating
    self.overall_rating = ((macro + micro + starsense + poise + speed) / 5.0).round
  end

  def effective_stats_for_phase(phase)
    modifier = send("#{phase}_game")
    {
      macro: [1, [100, macro + modifier].min].max,
      micro: [1, [100, micro + modifier].min].max,
      starsense: [1, [100, starsense + modifier].min].max,
      poise: [1, [100, poise + modifier].min].max,
      speed: [1, [100, speed + modifier].min].max
    }
  end

  def rarity_color
    case rarity
    when "common" then "#9ca3af"
    when "rare" then "#3b82f6"
    when "epic" then "#a855f7"
    when "legendary" then "#f59e0b"
    end
  end

  def race_icon
    case race
    when "Terran" then "🔧"
    when "Zerg" then "🐛"
    when "Protoss" then "⚡"
    when "Random" then "🎲"
    end
  end
end
