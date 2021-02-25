require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET/api/v1/articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago, status: 1) }
    let!(:article2) { create(:article, updated_at: 2.days.ago, status: 1) }
    let!(:article3) { create(:article, updated_at: 3.days.ago, status: 1) }

    it "公開されている記事一覧を取得できる" do
      subject
      aggregate_failures "最後まで通過" do
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
        expect(response).to have_http_status(:ok)
        expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id, article3.id]
      end
    end
  end

  describe "GET/api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id　の記事が存在するとき" do
      let(:article_id) { article.id }
      context "上記の記事が公開状態のとき" do
        let(:article) { create(:article, :published) }
        it "その記事のレコードを取得できる" do
          subject
          aggregate_failures "最後まで通過" do
            res = JSON.parse(response.body)
            expect(res["id"]).to eq article.id
            expect(res["title"]).to eq article.title
            expect(res["body"]).to eq article.body
            expect(res["updated_at"]).to be_present
            expect(res["user"]["id"]).to eq article.user.id
            expect(response).to have_http_status(:ok)
            expect(res["user"].keys).to eq ["id", "name", "email"]
          end
        end
      end
    end

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }
      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST/api/v1/articles" do
    subject { post(api_v1_articles_path, params: params, headers: user_header) }

    let(:current_user) { create(:user) }
    let(:user_header) { current_user.create_new_auth_token }

    context "ログインをしているユーザーから適切なパラメータが送信された時" do
      let(:params) { attributes_for(:article) }

      it "記事が作成される" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { Article.count }.by(1)
          res = JSON.parse(response.body)
          expect(res["title"]).to eq params[:title]
          expect(res["body"]).to eq params[:body]
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "適切なパラメータが送信されていない時" do
      let(:params) { attributes_for(:article, title: nil) }

      it "記事作成に失敗する" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "PATCH/api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: user_header) }

    let(:params) { attributes_for(:article) }
    let(:current_user) { create(:user) }
    let(:user_header) { current_user.create_new_auth_token }

    context "自分が所持しているきじのレコードを更新しようとしている時" do
      let(:article) { create(:article, user: current_user) }

      it "送信された記事データが更新される" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { current_user.articles.find_by(user_id: current_user.id).title }.from(article.title).to(params[:title]) &
                                change { current_user.articles.find_by(user_id: current_user.id).body }.from(article.body).to(params[:body])
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "自分が所持していない記事のレコードを更新しようとしている時" do
      let(:other_user) { create(:user) }
      let(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE/api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article.id), headers: user_header) }

    let(:current_user) { create(:user) }
    let(:user_header) { current_user.create_new_auth_token }

    context "自分が所持している記事を削除しようとしたとき" do
      let!(:article) { create(:article, user: current_user) }
      it "記事の削除に成功する" do
        expect { subject }.to change { current_user.articles.count }.by(-1)
      end
    end

    context "自分が所持していない記事を削除しようとしたとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "記事の削除に失敗する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
