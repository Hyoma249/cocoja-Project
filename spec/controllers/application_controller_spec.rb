require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user) }

  describe "#after_sign_in_path_for" do
    it "ログイン後にログインユーザー用トップページにリダイレクトすること" do
      expect(controller.after_sign_in_path_for(user)).to eq top_page_login_url(protocol: "https")
    end
  end

  describe "#redirect_if_authenticated" do
    # テスト用の一時的なコントローラーを定義
    class TestController < ApplicationController
      before_action :redirect_if_authenticated

      def index
        render plain: "Hello World"
      end
    end

    # テストで使用するルートを設定
    before do
      Rails.application.routes.draw do
        get "test" => "test#index"
        get "top_page_login", to: "top_page_login#top"
      end
      @controller = TestController.new
    end

    # テスト後に元のルートを復元
    after do
      Rails.application.reload_routes!
    end

    context "when logged in" do
      before do
        sign_in user
      end

      it "ログインユーザー用トップページにリダイレクトすること" do
        get :index
        expect(response).to redirect_to(top_page_login_path)
      end
    end

    context "when not logged in" do
      it "リダイレクトしないこと" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq "Hello World"
      end
    end
  end
end
