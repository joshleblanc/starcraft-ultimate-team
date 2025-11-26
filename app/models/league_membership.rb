class LeagueMembership < ApplicationRecord
  belongs_to :league
  belongs_to :team

  validates :team_id, uniqueness: { scope: :league_id, message: "is already in this league" }

  def record_match_result(won:, games_won:, games_lost:)
    new_points = points + (won ? 3 : 0) + (games_won > 0 && !won ? 1 : 0)
    
    update!(
      points: new_points,
      match_wins: match_wins + (won ? 1 : 0),
      match_losses: match_losses + (won ? 0 : 1),
      game_wins: game_wins + games_won,
      game_losses: game_losses + games_lost
    )
  end

  def game_differential
    game_wins - game_losses
  end
end
