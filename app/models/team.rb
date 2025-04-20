# app/models/team.rb
class Team < ApplicationRecord
  belongs_to :user
  belongs_to :captain, class_name: 'Player', optional: true
  belongs_to :vice_captain, class_name: 'Player', optional: true

  has_many :team_tournament_players, dependent: :destroy
  has_many :players, through: :team_tournament_players
  has_many :tournaments, through: :team_tournament_players

  # validates :name, presence: true, uniqueness: { scope: :user_id }
end
