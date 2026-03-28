class AddDetailsToMatches < ActiveRecord::Migration[7.1]
  def change
    add_reference :matches, :batting_team, null: true, foreign_key: { to_table: :teams }
    add_reference :matches, :bowling_team, null: true, foreign_key: { to_table: :teams }
    add_column :matches, :total_overs, :integer
  end
end
