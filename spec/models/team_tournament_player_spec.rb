# == Schema Information
#
# Table name: team_tournament_players
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  player_id     :bigint           not null
#  team_id       :bigint           not null
#  tournament_id :bigint           not null
#
# Indexes
#
#  index_team_tournament_players_on_player_id      (player_id)
#  index_team_tournament_players_on_team_id        (team_id)
#  index_team_tournament_players_on_tournament_id  (tournament_id)
#  index_unique_team_tournament_players            (player_id,team_id,tournament_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (tournament_id => tournaments.id)
#
require 'rails_helper'

RSpec.describe TeamTournamentPlayer, type: :model do
  it { should belong_to(:player) }
  it { should belong_to(:team) }
  it { should belong_to(:tournament).optional(true) }
end
