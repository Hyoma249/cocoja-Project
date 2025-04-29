require 'rails_helper'

RSpec.describe VotesController do
  let(:user) { create(:user) }
  let(:post_item) { create(:post) }

  describe 'POST #create' do
    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        post :create, params: { post_id: post_item.id, vote: { points: 1 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      context '正常なパラメータの場合' do
        let(:valid_params) do
          {
            post_id: post_item.id,
            vote: { points: 3 },
            format: :turbo_stream
          }
        end

        it '投票が作成されること' do
          expect {
            post :create, params: valid_params
          }.to change(Vote, :count).by(1)
        end

        it '投票が正しく保存されること' do
          post :create, params: valid_params
          expect(Vote.last.points).to eq 3
          expect(Vote.last.user).to eq user
          expect(Vote.last.post).to eq post_item
        end

        it 'フラッシュメッセージが設定されること' do
          post :create, params: valid_params
          expect(flash.now[:notice]).to eq "3ポイントを付与しました"
        end
      end

      context '不正なパラメータの場合' do
        let(:invalid_params) do
          {
            post_id: post_item.id,
            vote: { points: 0 },
            format: :turbo_stream
          }
        end

        it '投票が作成されないこと' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Vote, :count)
        end

        it 'エラーメッセージが設定されること' do
          post :create, params: invalid_params
          expect(flash.now[:alert]).to be_present
        end
      end

      context '1日の投票上限を超えた場合' do
        before do
          create(:vote, user: user, points: 4, post: create(:post))
        end

        let(:over_limit_params) do
          {
            post_id: post_item.id,
            vote: { points: 2 },
            format: :turbo_stream
          }
        end

        it '投票が作成されないこと' do
          expect {
            post :create, params: over_limit_params
          }.not_to change(Vote, :count)
        end

        it 'エラーメッセージが設定されること' do
          post :create, params: over_limit_params
          expect(flash.now[:alert]).to include("1日の投票ポイント上限")
        end
      end
    end
  end
end
