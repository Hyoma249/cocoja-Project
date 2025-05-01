# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投票機能', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:prefecture) { create(:prefecture) }
  let!(:post_item) { create(:post, user: other_user, prefecture: prefecture) }

  before do
    driven_by(:rack_test)
    sign_in user
    visit post_path(post_item)
  end

  describe 'ポイント付与' do
    describe '投票フォームの表示' do
      context 'when ログインユーザーの場合' do
        it '残りポイントが表示されること' do
          expect(page).to have_content '残りポイント: 5'
        end

        it '投票ボタンが表示されること' do
          within '#vote_form' do
            expect(page).to have_button '1'
            expect(page).to have_button '3'
            expect(page).to have_button '5'
          end
        end
      end

      context 'when 自分の投稿の場合' do
        let!(:my_post) { create(:post, user: user, prefecture: prefecture) }

        it '投票フォームが表示されないこと' do
          visit post_path(my_post)
          expect(page).to have_content '自分の投稿にはポイントを付けられません'
          expect(page).not_to have_content '残りポイント'
        end
      end

      context 'when ポイント上限に達している場合' do
        before do
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

      context 'when 投票済みの場合' do
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
      context 'when 新規投票の場合' do
        before do
          page.driver.submit :post, post_votes_path(post_item), { vote: { points: 3 } }
        end

        it 'ポイントが正しく記録されること' do
          vote = post_item.votes.last
          expect(vote.points).to eq 3
          expect(user.reload.remaining_daily_points).to eq 2
        end

        it '投票後のUIが適切に更新されること' do
          visit post_path(post_item)
          within('#vote_form') do
            expect(page).to have_content '既に今日ポイントを付けています'
            expect(page).not_to have_button '投票する'
          end
        end
      end

      context 'when 投票済みの場合' do
        it '再投票できないこと' do
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
end
