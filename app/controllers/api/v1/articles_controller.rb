module Api::V1
  class ArticlesController < BaseApiController
    def index
      articles = Article.all.order(updated_at: "DESC")
      render json: articles, each_serializer: Api::V1::ArticlesPreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end
  end
end
