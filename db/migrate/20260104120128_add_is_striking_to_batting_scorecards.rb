class AddIsStrikingToBattingScorecards < ActiveRecord::Migration[7.1]
  def change
    add_column :batting_scorecards, :is_striking, :boolean, default: false
  end
end
