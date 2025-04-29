require 'rails_helper'

RSpec.describe '投票機能' do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:prefecture) { create(:prefecture) }
  let!(:post_item) { create(:post, user: other_user, prefecture: prefecture) }

  describe 'ポイント付与' do
    before do
      login_as(user, scope: :user)
      visit post_path(post_item)
    end

    describe '投票フォームの表示' do
      context 'ログインユーザーの場合' do
        it 'ポイント選択ボタンと残りポイントが表示されること' do
          expect(page).to have_content '残りポイント: 5'
          expect(page).to have_button '1'
          expect(page).to have_button '2'
          expect(page).to have_button '3'
          expect(page).to have_button '4'
          expect(page).to have_button '5'
        end
      end

      context '自分の投稿の場合' do
        let!(:my_post) { create(:post, user: user, prefecture: prefecture) }

        it '投票フォームが表示されないこと' do
          visit post_path(my_post)
          expect(page).to have_content '自分の投稿にはポイントを付けられません'
          expect(page).not_to have_content '残りポイント'
        end
      end

      context '投票上限に達している場合' do
        before do
          # 上限まで投票を作成（factoryで直接作成）
          5.times do
            create(:vote, user: user, points: 1, post: create(:post, user: other_user))
          end
          visit post_path(post_item)
        end

        it '投票フォームが表示されないこと' do
          expect(page).to have_content '本日のポイント上限（5ポイント）に達しています'
          expect(page).not_to have_content '残りポイント'
        end
      end

      context '既に投票済みの場合' do
        before do
          create(:vote, user: user, points: 1, post: post_item)
          visit post_path(post_item)
        end

        it '投票フォームが表示されないこと' do
          expect(page).to have_content 'この投稿には既に今日ポイントを付けています'
          expect(page).not_to have_content '残りポイント'
        end
      end
    end

    describe '投票の実行' do
      before do
        login_as(user)
        visit post_path(post_item)
      end

      it '投票フォームから投票できること' do
        # 投票前の状態確認
        expect(user.remaining_daily_points).to eq 5
        expect(post_item.votes.count).to eq 0

        # フォームの送信
        page.driver.submit :post, post_votes_path(post_item), { vote: { points: 3 } }

        # データベースの状態を確認
        vote = post_item.votes.last
        expect(vote.points).to eq 3
        expect(user.reload.remaining_daily_points).to eq 2

        # ページの表示を確認
        visit post_path(post_item)
        within('#vote_form') do
          expect(page).to have_content '既に今日ポイントを付けています'
          expect(page).not_to have_button '投票する'
        end
      end

      it '投票済みの場合は再投票できないこと' do
        create(:vote, user: user, post: post_item, points: 1)
        visit post_path(post_item)

        within('#vote_form') do
          expect(page).to have_content '既に今日ポイントを付けています'
          expect(page).not_to have_button '投票する'
        end
      end
    end
  end
end
