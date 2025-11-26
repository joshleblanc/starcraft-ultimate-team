class League < ApplicationRecord
  STATUSES = %w[pending active completed].freeze

  has_many :league_memberships, dependent: :destroy
  has_many :teams, through: :league_memberships
  has_many :matches, dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :max_teams, numericality: { greater_than: 1, less_than_or_equal_to: 16 }

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }
  scope :joinable, -> { pending.where("(SELECT COUNT(*) FROM league_memberships WHERE league_id = leagues.id) < max_teams") }

  def full?
    league_memberships.count >= max_teams
  end

  def can_start?
    status == "pending" && league_memberships.count >= 2
  end

  def active?
    status == "active"
  end

  def completed?
    status == "completed"
  end

  def pending?
    status == "pending"
  end

  def start!
    return false unless can_start?

    transaction do
      update!(status: "active", started_at: Time.current, current_round: 1)
      generate_schedule
    end
    true
  end

  def standings
    league_memberships.includes(:team).order(points: :desc, game_wins: :desc)
  end

  def total_rounds
    # Round-robin: each team plays every other team once
    teams.count - 1
  end

  def current_round_matches
    matches.where(round: current_round)
  end

  def advance_round!
    return false if current_round >= total_rounds
    return false unless current_round_matches.all? { |m| m.status == "completed" }

    if current_round == total_rounds
      update!(status: "completed", ended_at: Time.current)
    else
      update!(current_round: current_round + 1)
    end
    true
  end

  private

  def generate_schedule
    team_ids = league_memberships.pluck(:team_id).shuffle
    round_robin_schedule(team_ids).each_with_index do |round_matches, round_index|
      round_matches.each do |home_id, away_id|
        next if home_id.nil? || away_id.nil?
        matches.create!(
          home_team_id: home_id,
          away_team_id: away_id,
          round: round_index + 1,
          status: "pending"
        )
      end
    end
    update!(total_rounds: team_ids.length - 1)
  end

  def round_robin_schedule(team_ids)
    teams = team_ids.dup
    teams << nil if teams.length.odd? # Add bye if odd number

    rounds = []
    (teams.length - 1).times do
      round_matches = []
      (teams.length / 2).times do |i|
        round_matches << [teams[i], teams[teams.length - 1 - i]]
      end
      rounds << round_matches
      # Rotate all except first team
      teams = [teams[0]] + [teams.last] + teams[1..-2]
    end
    rounds
  end
end
