# == Schema Information
#
# Table name: players
#
#  id            :bigint           not null, primary key
#  batting_style :string
#  bowling_style :string
#  date_of_birth :date
#  first_name    :string
#  last_name     :string
#  role          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_players_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :full_name, :role

  def full_name
    [object.first_name, object.last_name].compact.join(' ').strip
  end
end
