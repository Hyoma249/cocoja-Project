require 'rails_helper'

RSpec.describe SettingsController do
  describe 'GET #index' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログインしている場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it '正常にレスポンスを返すこと' do
        get :index
        expect(response).to be_successful
      end

      it 'indexテンプレートを表示すること' do
        get :index
        expect(response).to render_template :index
      end

      it '200ステータスコードを返すこと' do
        get :index
        expect(response).to have_http_status :ok
      end
    end
  end
end
