# == Schema Information
#
# Table name: matches
#
#  id                  :bigint           not null, primary key
#  match_date          :datetime
#  match_type          :string
#  result              :string
#  status              :string
#  toss_decision       :string
#  venue               :string
#  winning_margin      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  man_of_the_match_id :bigint
#  series_id           :bigint
#  team1_id            :bigint
#  team2_id            :bigint
#  toss_winner_id      :bigint
#  tournament_id       :bigint
#  user_id             :bigint           not null
#  winning_team_id     :bigint
#
# Indexes
#
#  index_matches_on_man_of_the_match_id  (man_of_the_match_id)
#  index_matches_on_series_id            (series_id)
#  index_matches_on_team1_id             (team1_id)
#  index_matches_on_team2_id             (team2_id)
#  index_matches_on_toss_winner_id       (toss_winner_id)
#  index_matches_on_tournament_id        (tournament_id)
#  index_matches_on_user_id              (user_id)
#  index_matches_on_winning_team_id      (winning_team_id)
#
# Foreign Keys
#
#  fk_rails_...  (man_of_the_match_id => players.id)
#  fk_rails_...  (series_id => series.id)
#  fk_rails_...  (team1_id => teams.id)
#  fk_rails_...  (team2_id => teams.id)
#  fk_rails_...  (toss_winner_id => teams.id)
#  fk_rails_...  (tournament_id => tournaments.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (winning_team_id => teams.id)
#
class Match < ApplicationRecord
  belongs_to :user
  belongs_to :series, optional: true
  belongs_to :tournament, optional: true
  belongs_to :team1, class_name: 'Team'
  belongs_to :team2, class_name: 'Team'
  belongs_to :toss_winner, class_name: 'Team', optional: true
  belongs_to :winning_team, class_name: 'Team', optional: true
  belongs_to :man_of_the_match, class_name: 'Player', optional: true

  has_many :innings, dependent: :destroy

  validates :match_date, presence: true
  validates :venue, presence: true
  validates :match_type, presence: true
  validates :status, presence: true
  validate :teams_must_be_different

  private

  def teams_must_be_different
    if team1_id.present? && team1_id == team2_id
      errors.add(:team2_id, "must be different from Team 1")
    end
  end
end
