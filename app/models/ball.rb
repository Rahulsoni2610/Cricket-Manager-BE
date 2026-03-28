# == Schema Information
#
# Table name: balls
#
#  id             :bigint           not null, primary key
#  ball_number    :integer
#  dismissal_type :string
#  extra_type     :string
#  is_bye         :boolean          default(FALSE), not null
#  is_wicket      :boolean
#  runs           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  batsman_id     :bigint           not null
#  bowler_id      :bigint           not null
#  fielder_id     :bigint
#  over_id        :bigint           not null
#
# Indexes
#
#  index_balls_on_batsman_id  (batsman_id)
#  index_balls_on_bowler_id   (bowler_id)
#  index_balls_on_fielder_id  (fielder_id)
#  index_balls_on_over_id     (over_id)
#
# Foreign Keys
#
#  fk_rails_...  (batsman_id => players.id)
#  fk_rails_...  (bowler_id => players.id)
#  fk_rails_...  (fielder_id => players.id)
#  fk_rails_...  (over_id => overs.id)
#
class Ball < ApplicationRecord
  belongs_to :over
  belongs_to :batsman, class_name: 'Player'
  belongs_to :bowler, class_name: 'Player'

  belongs_to :fielder, class_name: 'Player', optional: true

  validates :ball_number, presence: true
  validates :runs, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Extra types
  # nil/null = legal delivery
  VALID_EXTRAS = %w[wide no_ball bye leg_bye].freeze
  validates :extra_type, inclusion: { in: VALID_EXTRAS, allow_nil: true }

  VALID_DISMISSALS = %w[bowled caught lbw run_out stumped hit_wicket].freeze
  validates :dismissal_type, inclusion: { in: VALID_DISMISSALS, allow_nil: true }

  def legal_delivery?
    extra_type.nil? || %w[bye leg_bye].include?(extra_type)
  end

  def wicket?
    is_wicket
  end
end
