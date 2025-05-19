require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  describe 'アクセス制御' do
    context 'when 未ログインの場合' do
      it 'GET #setup はログインページにリダイレクトすること' do
        get :setup
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'PATCH #update はログインページにリダイレクトすること' do
        patch :update, params: { user: { username: 'newname' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'ログイン済みの場合' do
    let(:user) { create(:user) }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #setup' do
      before { get :setup }

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it 'setupテンプレートを表示すること' do
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/html')
      end

      it '@userに現在のユーザーを割り当てること' do
        expect(controller.instance_variable_get(:@user)).to eq user
      end
    end

    describe 'PATCH #update' do
      context 'when 有効なパラメータの場合' do
        let(:valid_attributes) { { username: 'newusername', uid: 'newuid123' } }

        before { patch :update, params: { user: valid_attributes } }

        it 'ユーザー情報を更新すること' do
          user.reload
          expect(user.username).to eq 'newusername'
          expect(user.uid).to eq 'newuid123'
        end

        it 'ログインページにリダイレクトすること' do
          expect(response).to redirect_to(top_page_login_url(protocol: 'https'))
        end

        it '成功メッセージを表示すること' do
          expect(flash[:notice]).to eq 'プロフィールを更新しました'
        end
      end

      context 'when 無効なパラメータの場合' do
        let(:invalid_attributes) { { username: '' } }

        before { patch :update, params: { user: invalid_attributes } }

        it 'ユーザー情報を更新しないこと' do
          expect { user.reload.username }.not_to change(user, :username)
        end

        it 'setupテンプレートを再表示すること' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('text/html')
        end

        it 'エラーメッセージを表示すること' do
          expect(flash.now[:alert]).to eq '入力内容に誤りがあります'
        end

        it 'ステータスコード422を返すこと' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
