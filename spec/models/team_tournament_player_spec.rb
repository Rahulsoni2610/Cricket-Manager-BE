require 'rails_helper'

RSpec.describe TeamTournamentPlayer, type: :model do
  it { should belong_to(:player) }
  it { should belong_to(:team) }
  it { should belong_to(:tournament).optional(true) }
end
