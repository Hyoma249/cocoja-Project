require 'rails_helper'

RSpec.describe 'ApplicationControllerのテスト', type: :controller do
  let(:user) { create(:user) }

  controller(ApplicationController) do  # 👈 ここで親クラスを指定！
    before_action :redirect_if_authenticated

    def index
      render plain: 'Hello World'
    end
  end

  describe '#after_sign_in_path_for' do
    it 'ログイン後にログインユーザー用トップページにリダイレクトすること' do
      expect(controller.after_sign_in_path_for(user)).to eq top_page_login_url(protocol: 'https')
    end
  end

  describe '#redirect_if_authenticated' do
    context 'ログインしている場合' do
      before { sign_in user }

      it 'ログインユーザー用トップページにリダイレクトすること' do
        get :index
        expect(response).to redirect_to(top_page_login_path)
      end
    end

    context 'ログインしていない場合' do
      it 'リダイレクトしないこと' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq 'Hello World'
      end
    end
  end
end
