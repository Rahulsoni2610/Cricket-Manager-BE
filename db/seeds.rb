# Create a user to associate with the tournament
user = User.find_or_create_by!(email: 'testuser@example.com', username: 'testuser') do |u|
  u.password = 'password'
end

# Create teams
team1 = Team.find_or_create_by!(name: 'Team A') do |team|
  team.home_ground = 'Stadium A'
  team.user = user
end
team2 = Team.find_or_create_by!(name: 'Team B') do |team|
  team.home_ground = 'Stadium B'
  team.user = user
end

# Create players and associate them with teams
player1 = Player.create!(first_name: 'Player', last_name: 'One', date_of_birth: Faker::Date.birthday(min_age: 20, max_age: 30), role: Player::ROLES.sample, user: user)
player2 = Player.create!(first_name: 'Player', last_name: 'Two', date_of_birth: Faker::Date.birthday(min_age: 20, max_age: 30), role: Player::ROLES.sample, user: user)

# Create a tournament
tournament = Tournament.create!(
  name: 'Spring Championship',
  start_date: Date.today,
  end_date: Date.today + 30,
  tournament_type: :round_robin,
  status: 'upcoming',
  user: user
)

# Associate teams with the tournament
TournamentTeam.create!(tournament: tournament, team: team1)
TournamentTeam.create!(tournament: tournament, team: team2)

# Associate players with the tournament through teams
TeamTournamentPlayer.create!(tournament: tournament, team: team1, player: player1)
TeamTournamentPlayer.create!(tournament: tournament, team: team2, player: player2)

require 'faker'

puts "Seeding new data..."

# Create one user
user = User.find_or_create_by(
  email: "admin@example.com",
  encrypted_password: "password",
  username: "admin"
)

# Create players
100.times do
  Player.create!(
    user_id: 1,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 40),
    batting_style: Player::BATTING_STYLES.sample,
    bowling_style: Player::BOWLING_STYLES.sample,
    role: Player::ROLES.sample
  )
end

puts "✅ Successfully created dummy data"
