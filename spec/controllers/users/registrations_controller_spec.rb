require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#create' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end

    context 'when 有効なパラメータの場合' do
      it 'ユーザーが作成されること' do
        expect do
          post :create, params: valid_params
        end.to change(User, :count).by(1)
      end

      it 'プロフィール設定ページにリダイレクトすること' do
        post :create, params: valid_params
        expect(response).to redirect_to(profile_setup_path)
      end

      it '自動的にログインすること' do
        post :create, params: valid_params
        expect(controller.current_user).to be_present
      end
    end

    context 'when 無効なパラメータの場合' do
      let(:invalid_params) do
        {
          user: {
            email: '',
            password: 'password',
            password_confirmation: 'different'
          }
        }
      end

      it 'ユーザーが作成されないこと' do
        expect do
          post :create, params: invalid_params
        end.not_to change(User, :count)
      end

      it 'newテンプレートを再表示すること' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include('text/html')
      end
    end
  end
end
