class TeamTournamentPlayer < ApplicationRecord
  belongs_to :player
  belongs_to :team
  belongs_to :tournament, optional: true

  validates :player_id, uniqueness: { scope: [:team_id, :tournament_id], message: "already exists in this team and tournament" }
end
