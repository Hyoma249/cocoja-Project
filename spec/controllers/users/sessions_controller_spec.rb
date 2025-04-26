require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#destroy' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'ログアウト後にrootページにリダイレクトすること' do
      delete :destroy
      expect(response).to redirect_to(root_url(protocol: 'https'))
    end

    it 'ログアウトメッセージを表示すること' do
      delete :destroy
      expect(flash[:notice]).to eq 'ログアウトしました'
    end
  end

  describe '#after_sign_in_path_for' do
    let(:user) { create(:user) }

    it 'ログインユーザー用トップページにリダイレクトすること' do
      post :create, params: { 
        user: { email: user.email, password: user.password } 
      }
      expect(response).to redirect_to(top_page_login_url(protocol: 'https'))
    end

    it 'ログインメッセージを表示すること' do
      post :create, params: { 
        user: { email: user.email, password: user.password } 
      }
      expect(flash[:notice]).to eq 'ログインしました'
    end
  end
end
