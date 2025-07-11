# == Schema Information
#
# Table name: players
#
#  id            :bigint           not null, primary key
#  batting_style :string
#  bowling_style :string
#  date_of_birth :date
#  first_name    :string
#  last_name     :string
#  role          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_players_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Player < ApplicationRecord
  belongs_to :user
  has_many :team_tournament_players, dependent: :destroy
  has_many :teams, through: :team_tournament_players
  has_many :tournaments, through: :team_tournament_players
  has_one_attached :picture

  BATTING_STYLES = %w[right_handed left_handed].freeze
  BOWLING_STYLES = %w[right_arm_fast right_arm_medium right_arm_spin left_arm_fast left_arm_medium left_arm_spin].freeze
  ROLES = %w[batsman bowler all_rounder wicketkeeper].freeze

  validates :first_name, presence: true
  validates :batting_style, inclusion: { in: BATTING_STYLES }, allow_nil: true
  validates :bowling_style, inclusion: { in: BOWLING_STYLES }, allow_nil: true
  validates :role, inclusion: { in: ROLES }, allow_nil: true
end
