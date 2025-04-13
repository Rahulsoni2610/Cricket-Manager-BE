class CreateBowlingScorecards < ActiveRecord::Migration[7.1]
  def change
    create_table :bowling_scorecards do |t|
      t.references :inning, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.decimal :overs
      t.integer :maidens
      t.integer :runs
      t.integer :wickets
      t.integer :no_balls
      t.integer :wides

      t.timestamps
    end
  end
end
