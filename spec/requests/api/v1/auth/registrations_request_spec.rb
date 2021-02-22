require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST/api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "正しい値を送信したとき" do
      let(:params) { attributes_for(:user) }
      it "ユーザーの新規登録に成功する" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { User.count }.by(1)
          res = JSON.parse(response.body)
          expect(res["data"]["name"]).to eq params[:name]
          expect(res["data"]["email"]).to eq params[:email]
          expect(res["status"]).to eq "success"
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

    context "emailの値を送信しなかった時" do
      let(:params) { attributes_for(:user, email: nil) }
      it "ユーザーの新規登録に失敗する" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { User.count }.by(0)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "error"
        end
      end
    end

    context "nameの値を送信しなかった時" do
      let(:params) { attributes_for(:user, name: nil) }
      it "ユーザーの新規登録に失敗する" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { User.count }.by(0)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "error"
        end
      end
    end

    context "passwordの値を送信しなかった時" do
      let(:params) { attributes_for(:user, password: nil) }
      it "ユーザーの新規登録に失敗する" do
        aggregate_failures "最後まで通過" do
          expect { subject }.to change { User.count }.by(0)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "error"
        end
      end
    end
  end
end
