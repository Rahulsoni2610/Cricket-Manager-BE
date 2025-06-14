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
