# == Schema Information
#
# Table name: series
#
#  id          :bigint           not null, primary key
#  end_date    :date
#  name        :string
#  series_type :string
#  start_date  :date
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_series_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Series < ApplicationRecord
  belongs_to :user
end
