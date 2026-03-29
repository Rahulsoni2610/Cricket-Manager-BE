# == Schema Information
#
# Table name: overs
#
#  id          :bigint           not null, primary key
#  over_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bowler_id   :bigint           not null
#  inning_id   :bigint           not null
#
# Indexes
#
#  index_overs_on_bowler_id  (bowler_id)
#  index_overs_on_inning_id  (inning_id)
#
# Foreign Keys
#
#  fk_rails_...  (bowler_id => players.id)
#  fk_rails_...  (inning_id => innings.id)
#
class Over < ApplicationRecord
  belongs_to :inning
  belongs_to :bowler, class_name: 'Player'

  has_many :balls, dependent: :destroy

  validates :over_number, presence: true
end
