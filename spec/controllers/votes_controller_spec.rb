require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  # テストで使用する変数を定義
  let(:user) { create(:user) }
  let(:post_item) { create(:post) }

  # 未ログインユーザーのテスト
  describe 'POST #create' do
    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        post :create, params: { post_id: post_item.id, vote: { points: 1 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    # ログインユーザーのテスト
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
            vote: { points: 0 }, # nilではなく不正な値（0）を使用
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

        context '1日の投票上限を超えた場合' do
          before do
            # 1日の上限が5ポイントなので、4ポイントを使用
            create(:vote, user: user, points: 4, post: create(:post))
          end

          it '投票が作成されないこと' do
            expect {
              post :create, params: {
                post_id: post_item.id,
                vote: { points: 2 }, # 残り1ポイントに対して2ポイントを投票しようとする
                format: :turbo_stream
              }
            }.not_to change(Vote, :count)
          end

          it 'エラーメッセージが設定されること' do
            post :create, params: {
              post_id: post_item.id,
              vote: { points: 2 },
              format: :turbo_stream
            }
            expect(flash.now[:alert]).to include("1日の投票ポイント上限")
          end
        end
      end
    end
  end
end
