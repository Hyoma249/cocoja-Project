require 'rails_helper'

RSpec.describe TopPageLoginController do
  describe 'GET #top' do
    context 'ログインしている場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '正常にレスポンスを返すこと' do
        get :top
        expect(response).to be_successful
      end

      it 'topテンプレートを表示すること' do
        get :top
        expect(response).to render_template :top
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get :top
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
