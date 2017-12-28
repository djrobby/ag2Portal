class Api::V1::UsersSerializer < ::Api::V1::BaseSerializer
  attributes :id, :email, :name, :text

  def text
    "#{name} (#{email})"
  end
end
