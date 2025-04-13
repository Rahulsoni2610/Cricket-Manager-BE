class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :user, null: false, foreign_key: true
      t.references :series, foreign_key: true
      t.references :tournament, foreign_key: true
      t.references :team1, foreign_key: { to_table: :teams }
      t.references :team2, foreign_key: { to_table: :teams }
      t.datetime :match_date
      t.string :venue
      t.string :match_type
      t.string :status
      t.references :toss_winner, foreign_key: { to_table: :teams }
      t.string :toss_decision
      t.string :result
      t.references :winning_team, foreign_key: { to_table: :teams }
      t.string :winning_margin
      t.references :man_of_the_match, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
