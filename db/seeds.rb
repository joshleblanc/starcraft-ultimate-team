# Starcraft II Ultimate Team - Seed Data
puts "🌱 Seeding database..."

# Pro Player Names by Race
TERRAN_PLAYERS = %w[Maru TY Clem HeRoMaRinE Bunny ByuN INnoVation GuMiho Dream Special]
ZERG_PLAYERS = %w[Serral Reynor Dark Rogue Solar Scarlett Lambo NightMare soO Nerchio]
PROTOSS_PLAYERS = %w[Stats herO Trap Zest Classic MaxPax PartinG Showtime Creator Neeb]

def generate_stats(rarity)
  base = case rarity
         when "legendary" then rand(75..90)
         when "epic" then rand(60..80)
         when "rare" then rand(45..70)
         else rand(30..60)
         end
  
  variance = 15
  {
    macro: [[base + rand(-variance..variance), 100].min, 1].max,
    micro: [[base + rand(-variance..variance), 100].min, 1].max,
    starsense: [[base + rand(-variance..variance), 100].min, 1].max,
    poise: [[base + rand(-variance..variance), 100].min, 1].max,
    speed: [[base + rand(-variance..variance), 100].min, 1].max,
    early_game: rand(-15..15),
    mid_game: rand(-15..15),
    late_game: rand(-15..15)
  }
end

# Create Cards
puts "Creating cards..."

[
  [TERRAN_PLAYERS, "Terran"],
  [ZERG_PLAYERS, "Zerg"],
  [PROTOSS_PLAYERS, "Protoss"]
].each do |players, race|
  players.each_with_index do |name, index|
    rarity = case index
             when 0..1 then "legendary"
             when 2..4 then "epic"
             when 5..7 then "rare"
             else "common"
             end
    
    stats = generate_stats(rarity)
    Card.find_or_create_by!(name: name, race: race) do |card|
      card.rarity = rarity
      card.macro = stats[:macro]
      card.micro = stats[:micro]
      card.starsense = stats[:starsense]
      card.poise = stats[:poise]
      card.speed = stats[:speed]
      card.early_game = stats[:early_game]
      card.mid_game = stats[:mid_game]
      card.late_game = stats[:late_game]
    end
  end
end

# Add some Random race players
%w[Has Bly PtitDrogo uThermal].each do |name|
  stats = generate_stats(%w[common rare epic].sample)
  Card.find_or_create_by!(name: name, race: "Random") do |card|
    card.rarity = %w[common rare epic].sample
    card.macro = stats[:macro]
    card.micro = stats[:micro]
    card.starsense = stats[:starsense]
    card.poise = stats[:poise]
    card.speed = stats[:speed]
    card.early_game = stats[:early_game]
    card.mid_game = stats[:mid_game]
    card.late_game = stats[:late_game]
  end
end

puts "Created #{Card.count} cards"

# Create Packs
puts "Creating packs..."

Pack.find_or_create_by!(name: "Standard Pack") do |pack|
  pack.pack_type = "standard"
  pack.card_count = 5
  pack.cost = 100
  pack.description = "A basic pack with 5 random cards"
  pack.common_weight = 70
  pack.rare_weight = 20
  pack.epic_weight = 8
  pack.legendary_weight = 2
end

Pack.find_or_create_by!(name: "Premium Pack") do |pack|
  pack.pack_type = "premium"
  pack.card_count = 5
  pack.cost = 300
  pack.description = "Better odds for rare and epic cards"
  pack.common_weight = 40
  pack.rare_weight = 35
  pack.epic_weight = 20
  pack.legendary_weight = 5
end

Pack.find_or_create_by!(name: "Legendary Pack") do |pack|
  pack.pack_type = "legendary"
  pack.card_count = 3
  pack.cost = 750
  pack.description = "Guaranteed epic or better!"
  pack.common_weight = 0
  pack.rare_weight = 0
  pack.epic_weight = 70
  pack.legendary_weight = 30
end

puts "Created #{Pack.count} packs"

# Create demo users with teams and cards (only in development)
if Rails.env.development?
  puts "Creating demo users..."
  
  demo_users = [
    { email: "player1@example.com", username: "ProGamer1" },
    { email: "player2@example.com", username: "SC2Master" },
    { email: "player3@example.com", username: "ZergRush" },
    { email: "player4@example.com", username: "ProtossPrime" }
  ]
  
  demo_users.each do |user_data|
    user = User.find_or_create_by!(email_address: user_data[:email]) do |u|
      u.password = "password123"
      u.username = user_data[:username]
      u.credits = 2000
    end
    
    # Give each user some random cards
    if user.user_cards.empty?
      Card.order("RANDOM()").limit(10).each_with_index do |card, index|
        user.user_cards.create!(
          card: card,
          is_starter: index < 5,
          position: index < 5 ? index + 1 : nil
        )
      end
    end
    
    # Create team if doesn't exist
    if user.teams.empty?
      user.teams.create!(name: "Team #{user.username}")
    end
    
    puts "  Created user: #{user.email_address} with #{user.user_cards.count} cards"
  end
  
  # Create a sample league
  if League.count == 0
    puts "Creating sample league..."
    league = League.create!(
      name: "Season 1 Cup Rush",
      max_teams: 8,
      status: "pending"
    )
    
    User.all.each do |user|
      team = user.active_team
      next unless team
      league.league_memberships.create!(team: team)
    end
    
    puts "Created league with #{league.teams.count} teams"
  end
end

puts "✅ Seeding complete!"
