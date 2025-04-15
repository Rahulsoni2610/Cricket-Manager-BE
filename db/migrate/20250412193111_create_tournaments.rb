class CreateTournaments < ActiveRecord::Migration[7.1]
  def change
    create_table :tournaments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :tournament_type
      t.integer :total_teams
      t.string :status

      t.timestamps
    end
  end
end
