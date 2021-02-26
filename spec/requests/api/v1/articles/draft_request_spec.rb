require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  describe "GET/api/v1/articles/drafts" do
    subject { get(api_v1_articles_draft_path, headers: user_header) }

    context "userがログインしていて" do
      let!(:current_user) { create(:user) }
      let!(:user_header) { current_user.create_new_auth_token }
      context "ログインしているuserの下書き状態の記事が存在するとき" do
        let!(:article1) { create(:article, status: 0, updated_at: 1.days.ago, user: current_user) }
        let!(:article2) { create(:article, status: 0, updated_at: 2.days.ago, user: current_user) }
        let!(:article3) { create(:article, status: 0, updated_at: 3.days.ago, user: current_user) }
        it "下書き記事の一覧を取得できる" do
          aggregate_failures "最後まで通過" do
            subject
            res = JSON.parse(response.body)
            expect(res.count).to eq 3
            expect(response).to have_http_status(:ok)
            expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
            expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id, article3.id]
          end
        end
      end

      context "ログインしているuserの下書き状態の記事が存在しないとき" do
        let!(:article1) { create(:article, status: 1, updated_at: 1.days.ago, user: current_user) }
        let!(:article2) { create(:article, status: 1, updated_at: 2.days.ago, user: current_user) }
        let!(:article3) { create(:article, status: 1, updated_at: 3.days.ago, user: current_user) }

        it "何も表示されない" do
          aggregate_failures "最後まで通過" do
            subject
            res = JSON.parse(response.body)
            expect(res).to eq []
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe "GET/api/v1/articles/draft/:id" do
    subject { get(api_v1_articles_path(article.id), headers: user_header) }

    context "userがログインしていて" do
      let!(:current_user) { create(:user) }
      let!(:user_header) { current_user.create_new_auth_token }
      context "指定したidの記事が下書き記事のとき" do
        let!(:article) { create(:article, status: 0, user: current_user) }

        it "指定した下書き記事を取得できる" do
          aggregate_failures "最後まで通過" do
            subject
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

      context "指定したidの記事が下書きでないとき" do
        let!(:article) { create(:article, status: 1, user: current_user) }
        it "エラーする" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
