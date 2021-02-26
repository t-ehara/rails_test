class Api::V1::Articles::DraftController < Api::V1::BaseApiController
  before_action :authenticate_user!, only: [:show, :index]

  def index
    articles = current_user.articles.draft.order(updated_at: "DESC")
    render json: articles, each_serializer: Api::V1::Articles::ArticleDraftSerializer
  end

  def show
    article = current_user.articles.draft.find(params[:id])
    render json: article, serializer: Api::V1::Articles::ArticleDraftDetailSerializer
  end
end
