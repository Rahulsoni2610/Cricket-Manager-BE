# == Schema Information
#
# Table name: teams
#
#  id              :bigint           not null, primary key
#  home_ground     :string
#  logo_url        :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  captain_id      :bigint
#  user_id         :bigint           not null
#  vice_captain_id :bigint
#
# Indexes
#
#  index_teams_on_captain_id       (captain_id)
#  index_teams_on_name             (name) UNIQUE
#  index_teams_on_user_id          (user_id)
#  index_teams_on_vice_captain_id  (vice_captain_id)
#
# Foreign Keys
#
#  fk_rails_...  (captain_id => players.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (vice_captain_id => players.id)
#
class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :home_ground, :created_at
  has_many :players
  belongs_to :captain
  belongs_to :vice_captain

  # has_many :team_tournament_players
  # has_many :tournaments

end
