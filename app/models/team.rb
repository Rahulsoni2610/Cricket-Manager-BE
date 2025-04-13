# app/models/team.rb
class Team < ApplicationRecord
  belongs_to :user
  has_many :players, dependent: :destroy
  has_many :home_matches, class_name: 'Match', foreign_key: 'team1_id', dependent: :nullify
  has_many :away_matches, class_name: 'Match', foreign_key: 'team2_id', dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
