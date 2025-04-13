class CreateInnings < ActiveRecord::Migration[7.1]
  def change
    create_table :innings do |t|
      t.references :match, null: false, foreign_key: true
      t.integer :number
      t.references :batting_team, foreign_key: { to_table: :teams }
      t.references :bowling_team, foreign_key: { to_table: :teams }
      t.integer :total_runs, default: 0
      t.integer :total_wickets, default: 0
      t.decimal :total_overs
      t.integer :extras, default: 0
      t.boolean :declared, default: false

      t.timestamps
    end
  end
end
