require 'rails_helper'

RSpec.describe MypagesController do
  let(:user) { create(:user) }

  describe 'アクセス制御' do
    context '未ログインの場合' do
      it 'showはログインページにリダイレクトすること' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'editはログインページにリダイレクトすること' do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'updateはログインページにリダイレクトすること' do
        patch :update, params: { user: { username: 'newname' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'ログイン済みの場合' do
    before { sign_in user }

    describe 'GET #show' do
      let!(:post1) { create(:post, user: user, created_at: 1.day.ago) }
      let!(:post2) { create(:post, user: user, created_at: 2.days.ago) }

      it '正常にレスポンスを返すこと' do
        get :show
        expect(response).to be_successful
      end

      it 'ユーザーの投稿を作成日時の降順で取得すること' do
        get :show
        expect(assigns(:posts)).to eq([ post1, post2 ])
      end

      context 'JSONフォーマットでリクエストされた場合' do
        it '正常にレスポンスを返すこと' do
          get :show, format: :json
          expect(response).to be_successful
        end
      end
    end

    describe 'GET #edit' do
      it '正常にレスポンスを返すこと' do
        get :edit
        expect(response).to be_successful
      end

      it '@userに現在のユーザーを割り当てること' do
        get :edit
        expect(assigns(:user)).to eq user
      end
    end

    describe 'PATCH #update' do
      context '有効なパラメータの場合' do
        let(:valid_params) do
          { user: { username: 'newname', bio: 'new bio' } }
        end

        it 'ユーザー情報を更新すること' do
          patch :update, params: valid_params
          user.reload
          expect(user.username).to eq 'newname'
          expect(user.bio).to eq 'new bio'
        end

        it 'マイページにリダイレクトすること' do
          patch :update, params: valid_params
          expect(response).to redirect_to(mypage_url(protocol: 'https'))
        end

        it '成功メッセージを表示すること' do
          patch :update, params: valid_params
          expect(flash[:notice]).to eq 'プロフィールを更新しました'
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) do
          { user: { username: '' } }  # usernameは必須
        end

        it 'ユーザー情報を更新しないこと' do
          expect {
            patch :update, params: invalid_params
          }.not_to change { user.reload.username }
        end

        it 'editテンプレートを再表示すること' do
          patch :update, params: invalid_params
          expect(response).to render_template :edit
        end

        it 'ステータスコード422を返すこと' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
