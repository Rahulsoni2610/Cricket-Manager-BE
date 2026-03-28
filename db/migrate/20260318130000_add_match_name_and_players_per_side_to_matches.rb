class AddMatchNameAndPlayersPerSideToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :match_name, :string
    add_column :matches, :players_per_side, :integer
  end
end
