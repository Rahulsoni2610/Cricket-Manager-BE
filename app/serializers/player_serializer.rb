class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :full_name, :role

  def full_name
    [object.first_name, object.last_name].compact.join(' ').strip
  end
end
