class AddUsernameToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :datetime
    add_column :users, :address, :string
    add_index :users, :first_name, unique: true
    add_index :users, :last_name, unique: true
  end
end
