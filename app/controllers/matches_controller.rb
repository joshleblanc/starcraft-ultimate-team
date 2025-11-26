class MatchesController < ApplicationController
  def index
    @team = current_user.active_team
    if @team
      @pending_matches = @team.matches.pending.includes(:home_team, :away_team, :league)
      @in_progress_matches = @team.matches.in_progress.includes(:home_team, :away_team, :league)
      @completed_matches = @team.matches.completed.includes(:home_team, :away_team, :winner_team, :league).order(completed_at: :desc).limit(20)
    else
      @pending_matches = @in_progress_matches = @completed_matches = []
    end
  end

  def show
    @match = Match.includes(:home_team, :away_team, :games, :league).find(params[:id])
    authorize @match
    @my_team = current_user.active_team
    @games = @match.games.includes(home_player: :card, away_player: :card)
    
    if @my_team && @match.is_participant?(@my_team)
      @my_lineup = @match.lineups.find_by(team: @my_team)
      opponent = @match.opponent_for(@my_team)
      @opponent_lineup = @match.lineups.find_by(team: opponent)
    end
  end

  def lineup
    @match = Match.find(params[:id])
    authorize @match, :submit_lineup?
    
    @team = current_user.active_team
    @lineup = @match.lineups.find_or_create_by!(team: @team)
    @available_cards = current_user.user_cards.includes(:card)
    @current_slots = @lineup.lineup_slots.includes(user_card: :card).index_by(&:position)
  end

  def submit_lineup
    @match = Match.find(params[:id])
    authorize @match, :submit_lineup?
    
    @team = current_user.active_team
    @lineup = @match.lineups.find_or_create_by!(team: @team)
    
    # Clear existing slots and set new ones
    @lineup.lineup_slots.destroy_all
    
    lineup_params[:players].each_with_index do |user_card_id, index|
      next if user_card_id.blank?
      user_card = current_user.user_cards.find(user_card_id)
      @lineup.lineup_slots.create!(user_card: user_card, position: index + 1)
    end

    if @lineup.complete? && @lineup.submit!
      redirect_to @match, notice: "Lineup submitted!"
    else
      redirect_to lineup_match_path(@match), alert: "Please select 5 players for your lineup."
    end
  end

  def simulate
    @match = Match.find(params[:id])
    authorize @match

    if @match.status == "lineup_submitted"
      @match.start_simulation!
    end

    if @match.status == "in_progress"
      @game = @match.simulate_next_game!
    end

    respond_to do |format|
      format.html { redirect_to @match }
      format.turbo_stream
    end
  end

  def simulate_all
    @match = Match.find(params[:id])
    authorize @match, :simulate?

    if @match.status == "lineup_submitted"
      @match.start_simulation!
    end

    @match.simulate_all!
    redirect_to @match, notice: "Match completed!"
  end

  private

  def lineup_params
    params.require(:lineup).permit(players: [])
  end
end
