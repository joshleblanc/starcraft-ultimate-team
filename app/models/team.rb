class Team < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cpu_cards, class_name: "UserCard", dependent: :destroy

  has_many :league_memberships, dependent: :destroy
  has_many :leagues, through: :league_memberships
  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id, dependent: :destroy
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id, dependent: :destroy
  has_many :lineups, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :user, presence: true, unless: :is_cpu?

  scope :cpu, -> { where(is_cpu: true) }
  scope :human, -> { where(is_cpu: false) }

  after_create :generate_cpu_roster, if: :is_cpu?

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", id, id)
  end

  def win_rate
    total = wins + losses
    return 0.0 if total.zero?
    (wins.to_f / total * 100).round(1)
  end

  def update_record(won:)
    if won
      increment!(:wins)
    else
      increment!(:losses)
    end
    update_rating(won)
  end

  def active_league
    league_memberships.joins(:league).where(leagues: { status: "active" }).first&.league
  end

  def starters
    is_cpu? ? cpu_cards.starters : user.user_cards.starters
  end

  def available_cards
    is_cpu? ? cpu_cards : user.user_cards
  end

  def auto_submit_lineup_for!(match)
    return unless is_cpu?

    lineup = match.lineups.find_or_create_by!(team: self)
    lineup.lineup_slots.destroy_all

    # Pick top 5 cards by overall rating
    top_cards = cpu_cards.joins(:card).order("cards.overall_rating DESC").limit(5)
    top_cards.each_with_index do |user_card, index|
      lineup.lineup_slots.create!(user_card: user_card, position: index + 1)
    end

    lineup.update!(submitted: true)
  end

  private

  def generate_cpu_roster
    # Give CPU team 8 random cards weighted toward their skill level
    skill_tier = %w[low mid high].sample
    8.times do |i|
      card = pick_card_for_tier(skill_tier)
      cpu_cards.create!(
        card: card,
        is_starter: i < 5,
        position: i < 5 ? i + 1 : nil
      )
    end
  end

  def pick_card_for_tier(tier)
    weights = case tier
    when "high" then { high: 15, mid_high: 30, mid: 35, low: 20 }
    when "mid" then { high: 5, mid_high: 15, mid: 40, low: 40 }
    else { high: 1, mid_high: 5, mid: 34, low: 60 }
    end

    roll = rand(100)
    cumulative = 0

    [
      [ "high", weights[:high], 85..92 ],
      [ "mid_high", weights[:mid_high], 75..84 ],
      [ "mid", weights[:mid], 65..74 ],
      [ "low", weights[:low], 50..64 ]
    ].each do |name, weight, range|
      cumulative += weight
      if roll < cumulative
        return Card.players.in_rating_range(range.min, range.max).order("RANDOM()").first ||
               Card.players.order("RANDOM()").first
      end
    end

    Card.players.order("RANDOM()").first
  end

  def update_rating(won)
    k_factor = 32
    change = won ? k_factor : -k_factor
    new_rating = [ rating + change, 100 ].max
    update!(rating: new_rating)
  end
end
