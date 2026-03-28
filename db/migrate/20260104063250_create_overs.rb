class CreateOvers < ActiveRecord::Migration[7.1]
  def change
    create_table :overs do |t|
      t.references :inning, null: false, foreign_key: true
      t.integer :over_number
      t.references :bowler, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
