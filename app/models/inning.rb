# == Schema Information
#
# Table name: innings
#
#  id              :bigint           not null, primary key
#  declared        :boolean          default(FALSE)
#  extras          :integer          default(0)
#  number          :integer
#  total_overs     :decimal(, )
#  total_runs      :integer          default(0)
#  total_wickets   :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  batting_team_id :bigint
#  bowling_team_id :bigint
#  match_id        :bigint           not null
#
# Indexes
#
#  index_innings_on_batting_team_id  (batting_team_id)
#  index_innings_on_bowling_team_id  (bowling_team_id)
#  index_innings_on_match_id         (match_id)
#
# Foreign Keys
#
#  fk_rails_...  (batting_team_id => teams.id)
#  fk_rails_...  (bowling_team_id => teams.id)
#  fk_rails_...  (match_id => matches.id)
#
class Inning < ApplicationRecord
  belongs_to :match
  belongs_to :batting_team, class_name: 'Team', foreign_key: 'batting_team_id'
  belongs_to :bowling_team, class_name: 'Team', foreign_key: 'bowling_team_id'
end
