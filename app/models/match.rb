class Match < ApplicationRecord
  STATUSES = %w[pending lineup_submitted in_progress completed].freeze
  GAMES_TO_WIN = 3 # Best of 5

  belongs_to :league
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  belongs_to :winner_team, class_name: "Team", optional: true

  has_many :games, -> { order(:game_number) }, dependent: :destroy
  has_many :lineups, dependent: :destroy

  validates :round, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :for_team, ->(team) { where("home_team_id = ? OR away_team_id = ?", team.id, team.id) }

  def home_lineup
    lineups.find_by(team: home_team)
  end

  def away_lineup
    lineups.find_by(team: away_team)
  end

  def both_lineups_submitted?
    home_lineup&.submitted? && away_lineup&.submitted?
  end

  def can_simulate?
    status == "lineup_submitted" && both_lineups_submitted?
  end

  def start_simulation!
    return false unless can_simulate?

    transaction do
      update!(status: "in_progress")
      create_games_from_lineups
    end
    true
  end

  def simulate_next_game!
    game = games.pending.first
    return nil unless game

    game.simulate!
    check_match_completion
    game
  end

  def simulate_all!
    return false unless status == "in_progress"

    while games.pending.exists? && !completed?
      simulate_next_game!
    end
    true
  end

  def completed?
    status == "completed"
  end

  def team_score(team)
    team == home_team ? home_score : away_score
  end

  def opponent_for(team)
    team == home_team ? away_team : home_team
  end

  def is_participant?(team)
    home_team_id == team.id || away_team_id == team.id
  end

  private

  def create_games_from_lineups
    home_slots = home_lineup.lineup_slots.order(:position)
    away_slots = away_lineup.lineup_slots.order(:position)

    5.times do |i|
      games.create!(
        game_number: i + 1,
        home_player: home_slots[i].user_card,
        away_player: away_slots[i].user_card,
        status: "pending"
      )
    end
  end

  def check_match_completion
    if home_score >= GAMES_TO_WIN
      complete_match!(home_team)
    elsif away_score >= GAMES_TO_WIN
      complete_match!(away_team)
    end
  end

  def complete_match!(winner)
    loser = winner == home_team ? away_team : home_team

    update!(
      status: "completed",
      winner_team: winner,
      completed_at: Time.current
    )

    # Update team records
    winner.update_record(won: true)
    loser.update_record(won: false)

    # Update league standings
    home_membership = league.league_memberships.find_by(team: home_team)
    away_membership = league.league_memberships.find_by(team: away_team)

    home_won = winner == home_team
    home_membership.record_match_result(won: home_won, games_won: home_score, games_lost: away_score)
    away_membership.record_match_result(won: !home_won, games_won: away_score, games_lost: home_score)

    # Send notifications
    MatchCompletedNotification.with(match: self).deliver(winner.user)
    MatchCompletedNotification.with(match: self).deliver(loser.user)
  end
end
