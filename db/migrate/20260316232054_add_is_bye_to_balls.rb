class AddIsByeToBalls < ActiveRecord::Migration[7.0]
  def change
    add_column :balls, :is_bye, :boolean, null: false, default: false
  end
end
