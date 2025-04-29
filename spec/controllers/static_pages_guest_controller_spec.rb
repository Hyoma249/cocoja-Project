require 'rails_helper'

RSpec.describe StaticPagesGuestController do
  describe 'GET #top' do
    context '未ログインの場合' do
      it '正常にレスポンスを返すこと' do
        get :top
        expect(response).to be_successful
      end

      it 'topテンプレートを表示すること' do
        get :top
        expect(response).to render_template :top
      end
    end

    context 'ログイン済みの場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'ログインユーザー用のトップページにリダイレクトされること' do
        get :top
        expect(response).to redirect_to(top_page_login_url(protocol: 'https'))
      end
    end
  end
end
