# == Schema Information
#
# Table name: match_players
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint           not null
#  player_id  :bigint           not null
#  team_id    :bigint           not null
#
# Indexes
#
#  index_match_players_on_match_id                (match_id)
#  index_match_players_on_match_id_and_player_id  (match_id,player_id) UNIQUE
#  index_match_players_on_player_id               (player_id)
#  index_match_players_on_team_id                 (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (match_id => matches.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (team_id => teams.id)
#
class MatchPlayer < ApplicationRecord
  belongs_to :match
  belongs_to :team
  belongs_to :player

  validate :player_belongs_to_team

  private

  def player_belongs_to_team
    return if team.blank? || player.blank?

    return if team.players.exists?(player.id)

    errors.add(:player_id, 'must belong to the selected team')
  end
end
