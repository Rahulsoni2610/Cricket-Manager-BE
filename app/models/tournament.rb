# app/models/tournament.rb
class Tournament < ApplicationRecord
  belongs_to :user
  has_many :series, dependent: :destroy
  has_many :matches, dependent: :destroy

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :tournament_type, presence: true
  validates :status, presence: true

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
