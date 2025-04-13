class BowlingScorecard < ApplicationRecord
  belongs_to :inning
  belongs_to :player
end
