class Inning < ApplicationRecord
  belongs_to :match
  belongs_to :batting_team, class_name: 'Team', foreign_key: 'batting_team_id'
  belongs_to :bowling_team, class_name: 'Team', foreign_key: 'bowling_team_id'
end
