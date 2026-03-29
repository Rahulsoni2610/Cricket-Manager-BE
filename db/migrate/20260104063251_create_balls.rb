class CreateBalls < ActiveRecord::Migration[7.1]
  def change
    create_table :balls do |t|
      t.references :over, null: false, foreign_key: true
      t.integer :ball_number
      t.integer :runs
      t.string :extra_type
      t.boolean :is_wicket
      t.references :batsman, null: false, foreign_key: { to_table: :players }
      t.references :bowler, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
