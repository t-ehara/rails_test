class Api::V1::Articles::ArticleDraftSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :updated_at
  belongs_to :user, serializer: Api::V1::UserSerializer
end
