class CupRushController < ApplicationController
  before_action :ensure_team

  def show
    @team = current_user.active_team
    @league = find_or_create_cup_rush_league
    @membership = @league.league_memberships.find_by(team: @team)
    @standings = @league.standings
    
    # Find next pending match for the player
    @next_match = @team.matches
      .where(league: @league)
      .where(status: %w[pending lineup_submitted in_progress])
      .order(:round)
      .first

    @recent_matches = @team.matches
      .where(league: @league)
      .completed
      .order(completed_at: :desc)
      .limit(5)
  end

  def new_season
    @team = current_user.active_team
    
    # Archive old cup rush leagues
    @team.leagues.where("name LIKE 'Cup Rush%'").update_all(status: "completed")
    
    # Create fresh league
    find_or_create_cup_rush_league
    
    redirect_to cup_rush_path, notice: "New Cup Rush season started!"
  end

  private

  def ensure_team
    unless current_user.active_team
      redirect_to new_team_path, alert: "Create a team first to play Cup Rush!"
    end
  end

  def find_or_create_cup_rush_league
    team = current_user.active_team
    
    # Look for existing active cup rush league for this player
    existing = team.leagues.find_by(name: "Cup Rush", status: %w[pending active])
    return existing if existing

    # Create new cup rush league
    league = League.create!(
      name: "Cup Rush",
      max_teams: 8,
      status: "pending"
    )

    # Add player's team
    league.league_memberships.create!(team: team)

    # Fill with CPU teams
    fill_with_cpu_teams(league)

    # Auto-start the league
    league.start!

    league
  end

  def fill_with_cpu_teams(league)
    needed = league.max_teams - league.teams.count
    
    # Try to use existing CPU teams not in this league
    available_cpu = Team.cpu.where.not(id: league.team_ids).order("RANDOM()").limit(needed)
    available_cpu.each do |cpu_team|
      league.league_memberships.create!(team: cpu_team)
    end

    # Generate new CPU teams if needed
    remaining = league.max_teams - league.teams.count
    remaining.times do |i|
      cpu_team = generate_cpu_team
      league.league_memberships.create!(team: cpu_team)
    end
  end

  def generate_cpu_team
    names = [
      "Nova Squadron", "Char Brood", "Shakuras Elite", "Korhal Guard",
      "Primal Pack", "Tal'darim Death Fleet", "Umojan Protectorate", 
      "Kel-Morian Combine", "Nerazim Shadows", "Cerebrate's Will",
      "Fenix Legion", "Mengsk's Fist", "Stukov's Infested", "Abathur's Evolution"
    ]
    
    # Find unused name
    existing = Team.pluck(:name)
    available = names - existing
    name = available.sample || "CPU Team #{rand(1000..9999)}"
    
    Team.create!(name: name, is_cpu: true, rating: rand(900..1100))
  end
end
