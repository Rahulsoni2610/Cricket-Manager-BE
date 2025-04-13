class CreateBattingScorecards < ActiveRecord::Migration[7.1]
  def change
    create_table :batting_scorecards do |t|
      t.references :inning, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :runs, default: 0
      t.integer :balls, default: 0
      t.integer :fours, default: 0
      t.integer :sixes, default: 0
      t.string :how_out
      t.references :bowler, foreign_key: { to_table: :players }
      t.references :fielder, foreign_key: { to_table: :players }
      t.integer :batting_position

      t.timestamps
    end
  end
end
