# Simulates a single Starcraft II game between two players
# The game progresses through 3 phases: early, mid, and late game
# Each phase can result in: home win, away win, or even (continue to next phase)
# The early/mid/late game stats modify the base stats for each phase
class GameSimulator
  NOISE_FACTOR = 15 # Random variance in performance
  ADVANTAGE_THRESHOLD = 12 # Difference needed to win a phase outright
  WIN_THRESHOLD = 20 # Difference needed to win the game in a phase
  
  attr_reader :game, :log

  def initialize(game)
    @game = game
    @log = []
  end

  def simulate
    home_card = game.home_player.card
    away_card = game.away_player.card
    
    log_event("Match begins: #{home_card.name} (#{home_card.race}) vs #{away_card.name} (#{away_card.race})")
    
    phases = {}
    home_momentum = 0
    away_momentum = 0
    
    %w[early mid late].each do |phase|
      result = simulate_phase(phase, home_card, away_card, home_momentum, away_momentum)
      phases[phase.to_sym] = result[:outcome]
      
      case result[:outcome]
      when "home"
        home_momentum += 5
        if result[:decisive]
          log_event("#{home_card.name} dominates the #{phase} game and wins!")
          return build_result(phases, :home, phase)
        end
      when "away"
        away_momentum += 5
        if result[:decisive]
          log_event("#{away_card.name} dominates the #{phase} game and wins!")
          return build_result(phases, :away, phase)
        end
      else
        log_event("The #{phase} game is even. Moving to next phase...")
      end
    end
    
    # If we get here, no one won decisively - determine winner by advantages
    home_advantages = phases.values.count("home")
    away_advantages = phases.values.count("away")
    
    winner = if home_advantages > away_advantages
      log_event("#{home_card.name} wins with more phase advantages!")
      :home
    elsif away_advantages > home_advantages
      log_event("#{away_card.name} wins with more phase advantages!")
      :away
    else
      # Tiebreaker: random with slight edge to higher overall
      tiebreaker = simulate_tiebreaker(home_card, away_card)
      log_event("Tiebreaker! #{tiebreaker == :home ? home_card.name : away_card.name} clutches the win!")
      tiebreaker
    end
    
    build_result(phases, winner, "late")
  end

  private

  def simulate_phase(phase, home_card, away_card, home_momentum, away_momentum)
    home_stats = home_card.effective_stats_for_phase(phase)
    away_stats = away_card.effective_stats_for_phase(phase)
    
    home_power = calculate_phase_power(home_stats, phase) + home_momentum + random_noise
    away_power = calculate_phase_power(away_stats, phase) + away_momentum + random_noise
    
    difference = home_power - away_power
    
    log_event("#{phase.capitalize} Game - #{home_card.name}: #{home_power.round} vs #{away_card.name}: #{away_power.round}")
    
    if difference.abs >= WIN_THRESHOLD
      { outcome: difference > 0 ? "home" : "away", decisive: true }
    elsif difference.abs >= ADVANTAGE_THRESHOLD
      { outcome: difference > 0 ? "home" : "away", decisive: false }
    else
      { outcome: "even", decisive: false }
    end
  end

  def calculate_phase_power(stats, phase)
    base_power = (stats[:macro] * 0.25 + 
                  stats[:micro] * 0.25 + 
                  stats[:starsense] * 0.20 + 
                  stats[:poise] * 0.15 + 
                  stats[:speed] * 0.15)
    
    # Phase-specific weightings
    case phase
    when "early"
      base_power * 0.9 + stats[:speed] * 0.1 # Early game rewards speed/aggression
    when "mid"
      base_power * 0.9 + stats[:starsense] * 0.1 # Mid game rewards game sense
    when "late"
      base_power * 0.9 + stats[:macro] * 0.1 # Late game rewards macro
    else
      base_power
    end
  end

  def simulate_tiebreaker(home_card, away_card)
    home_overall = home_card.overall_rating + random_noise
    away_overall = away_card.overall_rating + random_noise
    home_overall >= away_overall ? :home : :away
  end

  def random_noise
    (rand - 0.5) * NOISE_FACTOR * 2
  end

  def log_event(message)
    @log << { timestamp: Time.current.to_s, message: message }
  end

  def build_result(phases, winner, deciding_phase)
    {
      phases: phases,
      winner: winner,
      deciding_phase: deciding_phase,
      log: @log
    }
  end
end
