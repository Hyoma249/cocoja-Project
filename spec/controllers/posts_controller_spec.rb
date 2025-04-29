require 'rails_helper'

RSpec.describe PostsController do
  let(:user) { create(:user) }
  let(:prefecture) { create(:prefecture) }

  describe 'アクセス制御' do
    context '未ログインの場合' do
      it 'indexはログインページにリダイレクトすること' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'newはログインページにリダイレクトすること' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'createはログインページにリダイレクトすること' do
        post :create, params: { post: attributes_for(:post) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'ログイン済みの場合' do
    before { sign_in user }

    describe 'GET #index' do
      it '正常にレスポンスを返すこと' do
        get :index
        expect(response).to be_successful
      end

      context 'ハッシュタグでフィルタリングする場合' do
        let!(:hashtag) { create(:hashtag, name: 'test') }
        let!(:post_with_tag) { create(:post, user: user, hashtags: [ hashtag ]) }
        let!(:post_without_tag) { create(:post, user: user) }

        it 'タグに関連する投稿のみを表示すること' do
          get :index, params: { name: 'test' }
          expect(assigns(:posts)).to include(post_with_tag)
          expect(assigns(:posts)).not_to include(post_without_tag)
        end
      end
    end

    describe 'GET #new' do
      it '正常にレスポンスを返すこと' do
        get :new
        expect(response).to be_successful
      end

      it '@postに新しい投稿を割り当てること' do
        get :new
        expect(assigns(:post)).to be_a_new(Post)
      end

      it '@prefecturesに全ての都道府県を割り当てること' do
        get :new
        expect(assigns(:prefectures)).to eq Prefecture.all
      end
    end

    describe 'POST #create' do
      context '有効なパラメータの場合' do
        let(:valid_params) do
          {
            post: {
              content: 'テスト投稿',
              prefecture_id: prefecture.id,
              post_images_attributes: []
            }
          }
        end

        it '投稿が作成されること' do
          expect {
            post :create, params: valid_params
          }.to change(Post, :count).by(1)
        end

        it '投稿一覧ページにリダイレクトすること' do
          post :create, params: valid_params
          expect(response).to redirect_to(posts_url(protocol: 'https'))
        end

        it '成功メッセージが表示されること' do
          post :create, params: valid_params
          expect(flash[:notice]).to eq '投稿が作成されました'
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) do
          {
            post: {
              content: '',  # contentを空にする
              prefecture_id: nil  # prefecture_idもnilにする
            }
          }
        end

        before do
          post :create, params: invalid_params
        end

        it '投稿が作成されないこと' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Post, :count)
        end

        it 'newテンプレートを再表示すること' do
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'エラーメッセージを設定すること' do
          expect(flash.now[:notice]).to eq '投稿の作成に失敗しました'
        end
      end
    end

    describe 'GET #show' do
      let(:post_item) { create(:post, user: user) }

      it '正常にレスポンスを返すこと' do
        get :show, params: { id: post_item.id }
        expect(response).to be_successful
      end

      it '要求された投稿を表示すること' do
        get :show, params: { id: post_item.id }
        expect(assigns(:post)).to eq post_item
      end
    end
  end
end
