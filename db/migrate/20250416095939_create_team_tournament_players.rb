class CreateTeamTournamentPlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_tournament_players do |t|
      t.references :player, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end

    add_index :team_tournament_players, [:player_id, :team_id, :tournament_id], unique: true, name: 'index_unique_team_tournament_players'
  end
end
