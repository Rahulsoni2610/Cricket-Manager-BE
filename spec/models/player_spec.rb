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
require 'rails_helper'

RSpec.describe Player, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:team_tournament_players) }
  it { should validate_presence_of(:first_name) }
  it { should validate_inclusion_of(:batting_style).in_array(Player::BATTING_STYLES) }
  it { should validate_inclusion_of(:bowling_style).in_array(Player::BOWLING_STYLES) }
  it { should validate_inclusion_of(:role).in_array(Player::ROLES) }
end
