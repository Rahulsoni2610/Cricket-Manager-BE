# == Schema Information
#
# Table name: bowling_scorecards
#
#  id         :bigint           not null, primary key
#  maidens    :integer
#  no_balls   :integer
#  overs      :decimal(, )
#  runs       :integer
#  wickets    :integer
#  wides      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  inning_id  :bigint           not null
#  player_id  :bigint           not null
#
# Indexes
#
#  index_bowling_scorecards_on_inning_id  (inning_id)
#  index_bowling_scorecards_on_player_id  (player_id)
#
# Foreign Keys
#
#  fk_rails_...  (inning_id => innings.id)
#  fk_rails_...  (player_id => players.id)
#
class BowlingScorecard < ApplicationRecord
  belongs_to :inning
  belongs_to :player
end
