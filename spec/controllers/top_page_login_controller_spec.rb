# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TopPageLoginController, type: :controller do
  describe 'GET #top' do
    context 'when ログインしている場合' do
      let(:user) { create(:user) }

      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        get :top
      end

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it 'topテンプレートを表示すること' do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/html')
      end
    end

    context 'when ログインしていない場合' do
      it 'ログインページにリダイレクトされること' do
        get :top
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
