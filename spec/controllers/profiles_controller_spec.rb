require 'rails_helper'

RSpec.describe ProfilesController do
  describe 'アクセス制御' do
    context '未ログインの場合' do
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
      sign_in user
    end

    describe 'GET #setup' do
      it '正常にレスポンスを返すこと' do
        get :setup
        expect(response).to be_successful
      end

      it 'setupテンプレートを表示すること' do
        get :setup
        expect(response).to render_template :setup
      end

      it '@userに現在のユーザーを割り当てること' do
        get :setup
        expect(assigns(:user)).to eq user
      end
    end

    describe 'PATCH #update' do
      context '有効なパラメータの場合' do
        let(:valid_attributes) { { username: 'newusername', uid: 'newuid123' } }

        it 'ユーザー情報を更新すること' do
          patch :update, params: { user: valid_attributes }
          user.reload
          expect(user.username).to eq 'newusername'
          expect(user.uid).to eq 'newuid123'
        end

        it 'ログインページにリダイレクトすること' do
          patch :update, params: { user: valid_attributes }
          expect(response).to redirect_to(top_page_login_url(protocol: 'https'))
        end

        it '成功メッセージを表示すること' do
          patch :update, params: { user: valid_attributes }
          expect(flash[:notice]).to eq 'プロフィールが登録されました'
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_attributes) { { username: '' } }

        it 'ユーザー情報を更新しないこと' do
          expect {
            patch :update, params: { user: invalid_attributes }
          }.not_to change { user.reload.username }
        end

        it 'setupテンプレートを再表示すること' do
          patch :update, params: { user: invalid_attributes }
          expect(response).to render_template :setup
        end

        it 'エラーメッセージを表示すること' do
          patch :update, params: { user: invalid_attributes }
          expect(flash.now[:notice]).to eq 'プロフィール登録に失敗しました'
        end

        it 'ステータスコード422を返すこと' do
          patch :update, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
