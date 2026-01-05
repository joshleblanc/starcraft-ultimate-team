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

card_set = CardSet.create(name: "Default", description: "Default players")


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
      card.macro = stats[:macro]
      card.micro = stats[:micro]
      card.starsense = stats[:starsense]
      card.poise = stats[:poise]
      card.speed = stats[:speed]
      card.early_game = stats[:early_game]
      card.mid_game = stats[:mid_game]
      card.late_game = stats[:late_game]
      card.card_set = card_set
    end
  end
end


# Add some Random race players
%w[Has Bly PtitDrogo uThermal].each do |name|
  stats = generate_stats(%w[common rare epic].sample)
  Card.find_or_create_by!(name: name, race: "Random") do |card|
    card.macro = stats[:macro]
    card.micro = stats[:micro]
    card.starsense = stats[:starsense]
    card.poise = stats[:poise]
    card.speed = stats[:speed]
    card.early_game = stats[:early_game]
    card.mid_game = stats[:mid_game]
    card.late_game = stats[:late_game]
    card.card_set = card_set
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
end

Pack.find_or_create_by!(name: "Premium Pack") do |pack|
  pack.pack_type = "premium"
  pack.card_count = 5
  pack.cost = 300
  pack.description = "Better odds for rare and epic cards"
end

Pack.find_or_create_by!(name: "Legendary Pack") do |pack|
  pack.pack_type = "premium"
  pack.card_count = 3
  pack.cost = 750
  pack.description = "Guaranteed epic or better!"
end

puts "Created #{Pack.count} packs"

# Create demo user with team and cards (only in development)
if Rails.env.development?
  puts "Creating demo user..."

  user = User.find_or_create_by!(email_address: "player@example.com") do |u|
    u.password = "password123"
    u.username = "Commander"
    u.admin = true
    u.credits = 2000
  end

  # Give user some random cards
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
    user.teams.create!(name: "Team Commander")
  end

  puts "  Created user: #{user.email_address} with #{user.user_cards.count} cards"

  # Create CPU teams for Cup Rush
  puts "Creating CPU teams..."
  cpu_team_names = [
    "Koprulu Marines",
    "Aiur Guardians",
    "Swarm Collective",
    "Dominion Elite",
    "Dark Templar",
    "Overmind's Fury",
    "Raynor's Raiders"
  ]

  cpu_team_names.each do |name|
    next if Team.exists?(name: name)
    Team.create!(name: name, is_cpu: true, rating: rand(900..1100))
    puts "  Created CPU team: #{name}"
  end

  puts "CPU teams ready for Cup Rush - leagues auto-created when you start playing!"
end

puts "✅ Seeding complete!"
