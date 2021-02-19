require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET/api/v1/articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, updated_at: 3.days.ago) }

    it "ユーザーの一覧が取得できる" do
      subject
      aggregate_failures "最後まで通過" do
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(response).to have_http_status(:ok)
        expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id, article3.id]
      end
    end
  end

  describe "GET/api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id　の記事が存在するとき" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }
      it "その記事のレコードを取得できる" do
        subject
        aggregate_failures "最後まで通過" do
          res = JSON.parse(response.body)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(response).to have_http_status(:ok)
          expect(res["user"].keys).to eq ["id", "name", "email"]
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
end
