require 'rails_helper'

RSpec.describe MypagesController, type: :controller do
  let(:user) { create(:user) }

  describe 'アクセス制御' do
    context 'when 未ログインの場合' do
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
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    describe 'GET #show' do
      let!(:newer_post) { create(:post, user: user, created_at: 1.day.ago) }
      let!(:older_post) { create(:post, user: user, created_at: 2.days.ago) }

      before { get :show }

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it 'ユーザーの投稿を作成日時の降順で取得すること' do
        posts = controller.instance_variable_get(:@posts)
        expect(posts).to eq([newer_post, older_post])
      end

      context 'when JSONフォーマットでリクエストされた場合' do
        before { get :show, format: :json }

        it '正常にレスポンスを返すこと' do
          expect(response).to be_successful
        end
      end
    end

    describe 'GET #edit' do
      before { get :edit }

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it '@userに現在のユーザーを割り当てること' do
        expect(controller.instance_variable_get(:@user)).to eq(user)
      end
    end

    describe 'PATCH #update' do
      context 'when 有効なパラメータの場合' do
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

      context 'when 無効なパラメータの場合' do
        let(:invalid_params) do
          { user: { username: '' } }
        end

        before { patch :update, params: invalid_params }

        it 'ユーザー情報を更新しないこと' do
          expect { user.reload.username }.not_to change(user, :username)
        end

        it 'editテンプレートを再表示すること' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to include('text/html')
        end

        it 'ステータスコード422を返すこと' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
