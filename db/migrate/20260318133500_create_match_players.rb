class CreateMatchPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :match_players do |t|
      t.references :match, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.timestamps
    end

    add_index :match_players, [:match_id, :player_id], unique: true
  end
end
