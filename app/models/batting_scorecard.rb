# == Schema Information
#
# Table name: batting_scorecards
#
#  id               :bigint           not null, primary key
#  balls            :integer          default(0)
#  batting_position :integer
#  fours            :integer          default(0)
#  how_out          :string
#  runs             :integer          default(0)
#  sixes            :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bowler_id        :bigint
#  fielder_id       :bigint
#  inning_id        :bigint           not null
#  player_id        :bigint           not null
#
# Indexes
#
#  index_batting_scorecards_on_bowler_id   (bowler_id)
#  index_batting_scorecards_on_fielder_id  (fielder_id)
#  index_batting_scorecards_on_inning_id   (inning_id)
#  index_batting_scorecards_on_player_id   (player_id)
#
# Foreign Keys
#
#  fk_rails_...  (bowler_id => players.id)
#  fk_rails_...  (fielder_id => players.id)
#  fk_rails_...  (inning_id => innings.id)
#  fk_rails_...  (player_id => players.id)
#
class BattingScorecard < ApplicationRecord
  belongs_to :inning
  belongs_to :player
  belongs_to :bowler, class_name: 'Player', foreign_key: 'bowler_id'
  belongs_to :fielder, class_name: 'Player', foreign_key: 'fielder_id'
end
