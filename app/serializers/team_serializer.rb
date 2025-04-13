class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo_url, :home_ground, :created_at
  has_many :players
end
