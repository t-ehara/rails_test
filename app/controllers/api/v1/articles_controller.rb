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

    def create
      article = current_user.articles.create!(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def update
      article = current_user.articles.find(params[:id])
      article.update!(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def destroy
      article = current_user.articles.find(params[:id])
      article.destroy!
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    private

      def article_params
        params.permit(:title, :body)
      end
  end
end
