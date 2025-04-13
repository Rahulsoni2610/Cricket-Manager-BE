puts "Seeding new data..."

# Create one user
user = User.create!(
  email: "admin@example.com",
  password: "password",
  username: "admin"
)

# Create 4 teams
teams = 4.times.map do |i|
  Team.create!(
    user: user,
    name: "Team #{i + 1}",
    logo_url: "",
    home_ground: "Ground #{i + 1}"
  )
end

# Create 8 players per team
teams.each do |team|
  8.times do |i|
    Player.create!(
      user: user,
      team: team,
      first_name: "Player#{i + 1}",
      last_name: team.name.split.last,
      date_of_birth: Date.new(rand(1985..2005), rand(1..12), rand(1..28)),
      batting_style: %w[right_handed left_handed].sample,
      bowling_style: %w[right_arm_fast right_arm_medium right_arm_spin left_arm_fast left_arm_medium left_arm_spin].sample,
      role: %w[batsman bowler all_rounder wicketkeeper].sample
    )
  end
end

# Create 2 tournaments
tournaments = 2.times.map do |i|
  Tournament.create!(
    user: user,
    name: "Tournament #{i + 1}",
    start_date: Date.today + i,
    end_date: Date.today + 30 + i,
    tournament_type: "Knockout",
    status: "Scheduled"
  )
end

# Create 2 series per tournament
series_list = tournaments.flat_map do |tournament|
  2.times.map do |i|
    Series.create!(
      user: user,
      tournament: tournament,
      name: "#{tournament.name} - Series #{i + 1}",
      start_date: tournament.start_date + i,
      end_date: tournament.end_date - i,
      series_type: "Best of 3",
      status: "Scheduled"
    )
  end
end

# Create 5 matches using random teams and series
matches = 5.times.map do |i|
  team1, team2 = teams.sample(2)
  match = Match.create!(
    user: user,
    series: series_list.sample,
    tournament: tournaments.sample,
    team1: team1,
    team2: team2,
    match_date: Date.today + i,
    venue: "Stadium #{i + 1}",
    match_type: "ODI",
    status: "Scheduled",
    toss_winner: [team1, team2].sample,
    toss_decision: ["bat", "bowl"].sample,
    result: nil,
    winning_team: nil,
    winning_margin: nil,
    man_of_the_match: nil
  )

  # Create innings for each team
  [team1, team2].each_with_index do |batting_team, idx|
    bowling_team = (batting_team == team1 ? team2 : team1)
    inning = Inning.create!(
      match: match,
      number: idx + 1,
      batting_team: batting_team,
      bowling_team: bowling_team,
      total_runs: rand(100..300),
      total_wickets: rand(3..10),
      total_overs: rand(15.0..50.0).round(1),
      extras: rand(5..20),
      declared: false
    )

    # Create batting scorecards
    batting_team.players.limit(5).each_with_index do |player, pos|
      BattingScorecard.create!(
        inning: inning,
        player: player,
        runs: rand(0..100),
        balls: rand(10..80),
        fours: rand(0..10),
        sixes: rand(0..5),
        how_out: ["bowled", "caught", "lbw", "run out", "not out"].sample,
        bowler_id: bowling_team.players.sample.id,
        fielder_id: bowling_team.players.sample.id,
        batting_position: pos + 1
      )
    end

    # Create bowling scorecards
    bowling_team.players.limit(4).each do |player|
      BowlingScorecard.create!(
        inning: inning,
        player: player,
        overs: rand(2.0..10.0).round(1),
        maidens: rand(0..3),
        runs: rand(10..60),
        wickets: rand(0..4),
        no_balls: rand(0..2),
        wides: rand(0..3)
      )
    end
  end

  match
end

puts "✅ Seeding complete: #{User.count} user(s), #{Team.count} teams, #{Player.count} players, #{Match.count} matches"
