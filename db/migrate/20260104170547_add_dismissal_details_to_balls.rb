class AddDismissalDetailsToBalls < ActiveRecord::Migration[7.1]
  def change
    add_column :balls, :dismissal_type, :string
    add_reference :balls, :fielder, null: true, foreign_key: { to_table: :players }
  end
end
