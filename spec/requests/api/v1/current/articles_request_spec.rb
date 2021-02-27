require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET/api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: user_header) }

    context "ログインしているユーザーがいて" do
      let(:current_user) { create(:user) }
      let(:user_header) { current_user.create_new_auth_token }

      context "ログインユーザーが公開状態の記事を持っているとき" do
        let!(:article1) { create(:article, status: 1, updated_at: 1.days.ago, user: current_user) }
        let!(:article2) { create(:article, status: 1, updated_at: 2.days.ago, user: current_user) }
        let!(:article3) { create(:article, status: 1, updated_at: 3.days.ago, user: current_user) }
        it "自分の公開記事一覧を取得できる" do
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

      context "ログインユーザーが公開記事を持っていないとき" do
        let!(:article1) { create(:article, status: 0, updated_at: 1.days.ago, user: current_user) }
        let!(:article2) { create(:article, status: 0, updated_at: 2.days.ago, user: current_user) }
        let!(:article3) { create(:article, status: 0, updated_at: 3.days.ago, user: current_user) }

        it "何も取得できない" do
          aggregate_failures "最後まで通過" do
            subject
            res = JSON.parse(response.body)
            expect(res).to eq []
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    context "別のユーザーの公開記事を取得しようとしたとき" do
      let(:current_user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:user_header) { other_user.create_new_auth_token }
      let!(:article1) { create(:article, status: 1, updated_at: 1.days.ago, user: current_user) }
      let!(:article2) { create(:article, status: 1, updated_at: 2.days.ago, user: current_user) }
      it "公開記事一覧を取得できない" do
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
