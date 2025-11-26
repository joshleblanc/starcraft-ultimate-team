class LeaguesController < ApplicationController
  def index
    @active_leagues = League.active.includes(:teams)
    @pending_leagues = League.pending.includes(:teams)
    @my_leagues = current_user.active_team&.leagues || League.none
  end

  def show
    @league = League.includes(:teams, :matches).find(params[:id])
    authorize @league
    @standings = @league.standings.includes(team: :user)
    @current_round_matches = @league.current_round_matches.includes(:home_team, :away_team, :winner_team)
    @my_team = current_user.active_team
  end

  def new
    @league = League.new
    authorize @league
  end

  def create
    @league = League.new(league_params)
    authorize @league

    if @league.save
      # Auto-join with current user's team
      if current_user.active_team
        @league.league_memberships.create!(team: current_user.active_team)
      end
      redirect_to @league, notice: "League created! Invite other players to join."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join
    @league = League.find(params[:id])
    authorize @league

    membership = @league.league_memberships.new(team: current_user.active_team)

    if membership.save
      redirect_to @league, notice: "You joined #{@league.name}!"
    else
      redirect_to @league, alert: membership.errors.full_messages.join(", ")
    end
  end

  def start
    @league = League.find(params[:id])
    authorize @league

    if @league.start!
      # Notify all participants
      @league.teams.each do |team|
        LeagueStartedNotification.with(league: @league).deliver(team.user)
      end
      redirect_to @league, notice: "League started! Check your matches."
    else
      redirect_to @league, alert: "Cannot start league yet. Need at least 2 teams."
    end
  end

  private

  def league_params
    params.require(:league).permit(:name, :max_teams)
  end
end
