class BattingScorecard < ApplicationRecord
  belongs_to :inning
  belongs_to :player
  belongs_to :bowler, class_name: 'Player', foreign_key: 'bowler_id'
  belongs_to :fielder, class_name: 'Player', foreign_key: 'fielder_id'
end
