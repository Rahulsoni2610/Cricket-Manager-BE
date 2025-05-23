class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :logo_url
      t.string :home_ground
      t.references :captain, foreign_key: { to_table: :players }
      t.references :vice_captain, foreign_key: { to_table: :players }


      t.timestamps
    end
    add_index :teams, :name, unique: true
  end
end
