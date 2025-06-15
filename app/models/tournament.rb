# == Schema Information
#
# Table name: tournaments
#
#  id              :bigint           not null, primary key
#  end_date        :date
#  name            :string
#  start_date      :date
#  status          :string
#  total_teams     :integer
#  tournament_type :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_tournaments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Tournament < ApplicationRecord
  belongs_to :user
  has_many :matches, dependent: :destroy
  has_many :tournament_teams, dependent: :destroy
  has_many :teams, through: :tournament_teams

  has_many :team_tournament_players, dependent: :destroy
  has_many :players, through: :team_tournament_players
  has_many :teams, through: :team_tournament_players

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :tournament_type, presence: true
  validates :status, presence: true

  validate :end_date_after_start_date

  enum tournament_type: { round_robin: 0, knockout: 1, league: 2, single_elimination: 3 }


  # after_save :generate_or_update_matches, if: :saved_change_to_tournament_type?

  before_destroy :delete_matches

  private

  def generate_or_update_matches
    self.matches.destroy_all

    case tournament_type
    when 'round_robin'
      generate_round_robin_matches
    when 'knockout'
      generate_knockout_matches
    when 'league'
      generate_league_matches
    when 'single_elimination'
      generate_single_elimination_matches
    else
      raise 'Invalid tournament type'
    end
  end

  def generate_round_robin_matches
    teams = self.teams
    teams.each do |team1|
      teams.each do |team2|
        next if team1 == team2

        Match.create(
          tournament_id: self.id,
          team1_id: team1.id,
          team2_id: team2.id,
          match_type: 'Group Stage',
          status: 'upcoming'
        )
      end
    end
  end

  def generate_knockout_matches
    teams = self.teams.shuffle
    teams.each_slice(2) do |team1, team2|
      Match.create(
        tournament_id: self.id,
        team1_id: team1.id,
        team2_id: team2.id,
        match_type: 'Round of 16', # Example, you can make this dynamic
        status: 'upcoming'
      )
    end
  end

  def generate_league_matches
    teams = self.teams
    teams.each do |team1|
      teams.each do |team2|
        next if team1 == team2

        Match.create(
          tournament_id: self.id,
          team1_id: team1.id,
          team2_id: team2.id,
          match_type: 'Group Stage',
          status: 'upcoming'
        )
      end
    end
  end

  def delete_matches
    self.matches.destroy_all
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
