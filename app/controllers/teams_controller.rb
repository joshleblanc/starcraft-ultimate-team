class TeamsController < ApplicationController
  def index
    @teams = Team.includes(:user).order(rating: :desc).limit(50)
  end

  def show
    @team = Team.includes(:user, :league_memberships).find(params[:id])
    authorize @team
    @recent_matches = @team.matches.includes(:home_team, :away_team, :winner_team).order(created_at: :desc).limit(10)
  end

  def new
    @team = Team.new
    authorize @team
  end

  def create
    @team = current_user.teams.build(team_params)
    authorize @team

    if @team.save
      redirect_to @team, notice: "Team created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @team = current_user.teams.find(params[:id])
    authorize @team
  end

  def update
    @team = current_user.teams.find(params[:id])
    authorize @team

    if @team.update(team_params)
      redirect_to @team, notice: "Team updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
