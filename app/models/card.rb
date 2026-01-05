class Card < ApplicationRecord
  RACES = %w[Terran Zerg Protoss Random].freeze
  ROLES = %w[player coach].freeze

  belongs_to :card_set

  has_many :user_cards, dependent: :destroy
  has_many :users, through: :user_cards

  validates :name, presence: true
  validates :race, presence: true, inclusion: { in: RACES }
  validates :player_role, inclusion: { in: ROLES }

  validates :macro, :micro, :starsense, :poise, :speed,
            numericality: { in: 1..100 }
  validates :early_game, :mid_game, :late_game,
            numericality: { in: -30..30 }

  scope :by_race, ->(race) { where(race: race) }
  scope :players, -> { where(player_role: "player") }
  scope :by_card_set, ->(set) { where(card_set_id: set) }
  scope :in_rating_range, ->(min, max) { where(overall_rating: min..max) }

  before_save :calculate_overall_rating

  def calculate_overall_rating
    self.overall_rating = ((macro + micro + starsense + poise + speed) / 5.0).round
  end

  def effective_stats_for_phase(phase)
    modifier = send("#{phase}_game")
    {
      macro: [ 1, [ 100, macro + modifier ].min ].max,
      micro: [ 1, [ 100, micro + modifier ].min ].max,
      starsense: [ 1, [ 100, starsense + modifier ].min ].max,
      poise: [ 1, [ 100, poise + modifier ].min ].max,
      speed: [ 1, [ 100, speed + modifier ].min ].max
    }
  end

  def rarity_color
    case overall_rating
    when 50..64 then "#9ca3af"
    when 65..74 then "#3b82f6"
    when 75..84 then "#a855f7"
    when 85..92 then "#10b981"
    when 93..96 then "#f59e0b"
    else "#ef4444"
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

  def rating_tier
    case overall_rating
    when 50..64 then "bronze"
    when 65..74 then "silver"
    when 75..84 then "gold"
    when 85..92 then "diamond"
    when 93..96 then "master"
    else "legend"
    end
  end
end
