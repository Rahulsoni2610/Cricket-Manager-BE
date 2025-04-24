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
