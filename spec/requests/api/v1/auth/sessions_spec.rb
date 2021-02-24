require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST/api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "適切な値が送信されたとき" do
      let(:user) { create(:user) }
      let(:params) { { email: user.email, password: user.password } }
      it "ログインに成功する" do
        aggregate_failures "最後まで通過" do
          subject
          res = JSON.parse(response.body)
          expect(res["data"]["name"]).to eq user.name
          expect(res["data"]["email"]).to eq user.email
          expect(response).to have_http_status(:ok)
        end
      end

      it "header情報を取得することができる" do
        aggregate_failures "最後まで通過" do
          subject
          header = response.header
          expect(header["access-token"]).to be_present
          expect(header["token-type"]).to be_present
          expect(header["client"]).to be_present
          expect(header["expiry"]).to be_present
          expect(header["uid"]).to be_present
        end
      end
    end

    context "異なる email の値が送信されたとき" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:params) { { email: other_user.email, password: user.password } }
      it "ログインに失敗する" do
        aggregate_failures "最後まで通過" do
          subject
          res = JSON.parse(response.body)
          expect(res["success"]).to eq false
          expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        end
      end
    end

    context "異なる passwordの値が送信されたとき" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:params) { { email: user.email, password: other_user.password } }
      it "ログインに失敗する" do
        aggregate_failures "最後まで通過" do
          subject
          res = JSON.parse(response.body)
          expect(res["success"]).to eq false
          expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        end
      end
    end
  end

  describe "DELETE/api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: user_header) }

    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: user.password } }

    context "ログアウトに必要な情報を送信したとき" do
      let(:user_header) { user.create_new_auth_token }
      it "ログアウトに成功する" do
        aggregate_failures "最後まで通過" do
          post(api_v1_user_session_path, params: params)
          subject
          res = JSON.parse(response.body)
          expect(res["success"]).to be_truthy
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "ログアウトに必要な情報を送信していないとき" do
      let(:user_header) { { "access-token": nil, "token-type": nil, "client": nil, "expiry": nil, "uid": nil } }
      it "ログアウトできない" do
        aggregate_failures "最後まで通過" do
          post(api_v1_user_session_path, params: params)
          subject
          res = JSON.parse(response.body)
          expect(res["success"]).to eq false
          expect(res["errors"]).to eq ["User was not found or was not logged in."]
        end
      end
    end
  end
end
