class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :home_ground, :created_at
  has_many :players
  belongs_to :captain
  belongs_to :vice_captain

  # has_many :team_tournament_players
  # has_many :tournaments

end
