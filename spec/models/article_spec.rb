# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default(0), not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "titleが指定されている時" do
    let!(:article) { build(:article, title: "yyy") }
    it "articleが作成される" do
      expect(article).to be_valid
    end
  end

  context "titleが指定されていない時" do
    let!(:article) { build(:article, title: nil) }
    it "articleの作成に失敗する" do
      expect(article).to be_invalid
    end
  end

  context "titleが30文字以上の時" do
    let!(:article) { build(:article, title: Faker::Alphanumeric.alpha(number: 31)) }
    it "articleの作成に失敗する" do
      expect(article).to be_invalid
    end
  end

  context "status を draft に設定した記事を作成した場合" do
    let!(:article) { create(:article, :draft) }
    it "下書き状態の記事が作成される" do
      aggregate_failures "最後まで通過" do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
        expect(Article.draft.count).to eq 1
      end
    end
  end

  context "記事のstatusが公開状態になっている時" do
    let!(:article) { create(:article, :published) }
    it "記事を公開することができる" do
      aggregate_failures "最後まで通過" do
        expect(article).to be_valid
        expect(article.status).to eq "published"
        expect(Article.published.count).to eq 1
      end
    end
  end
end
