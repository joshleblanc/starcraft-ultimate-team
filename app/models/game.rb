class Game < ApplicationRecord
  STATUSES = %w[pending in_progress completed].freeze
  PHASES = %w[early mid late].freeze
  PHASE_RESULTS = %w[home away even].freeze

  belongs_to :match
  belongs_to :home_player, class_name: "UserCard"
  belongs_to :away_player, class_name: "UserCard"
  belongs_to :winner_player, class_name: "UserCard", optional: true
  belongs_to :winner_team, class_name: "Team", optional: true

  validates :game_number, presence: true, numericality: { in: 1..5 }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }

  def simulate!
    return false unless status == "pending"

    update!(status: "in_progress")
    
    result = GameSimulator.new(self).simulate
    
    update!(
      status: "completed",
      early_game_result: result[:phases][:early],
      mid_game_result: result[:phases][:mid],
      late_game_result: result[:phases][:late],
      deciding_phase: result[:deciding_phase],
      winner_player: result[:winner] == :home ? home_player : away_player,
      winner_team: result[:winner] == :home ? match.home_team : match.away_team,
      simulation_log: result[:log]
    )

    # Update match score
    if winner_team == match.home_team
      match.increment!(:home_score)
    else
      match.increment!(:away_score)
    end

    self
  end

  def home_won?
    winner_team_id == match.home_team_id
  end

  def away_won?
    winner_team_id == match.away_team_id
  end

  def phase_winner(phase)
    result = send("#{phase}_game_result")
    case result
    when "home" then home_player
    when "away" then away_player
    else nil
    end
  end
end
