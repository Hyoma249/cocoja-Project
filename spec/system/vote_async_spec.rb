require 'rails_helper'

RSpec.describe '投票の非同期更新', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:prefecture) { create(:prefecture) }
  let!(:post) { create(:post, user: other_user, prefecture: prefecture) }

  describe 'Turbo Streamsでの投票更新' do
    before do
      # JavaScriptを有効化
      driven_by(:selenium_chrome_headless)
      login_as(user)
      visit post_path(post)
    end

    it '投票後に画面が非同期更新されること', js: true do
      # 投票前の状態を確認
      expect(page).to have_content '残りポイント: 5'
      within('#vote_form') do
        expect(page).to have_button '1'
      end

      # 投票実行
      click_button '1'
      click_button '投票する'

      # Turbo Streamsによる更新を待機
      expect(page).to have_content 'ポイントを付与しました', wait: 5

      # フォームの状態が更新されていることを確認
      expect(page).to have_content '残りポイント: 4'
      expect(page).to have_content 'この投稿には既に今日ポイントを付けています'
    end

    it 'エラー時にメッセージが表示されること', js: true do
      # すでに投票済みの状態を作る
      create(:vote, user: user, post: post, points: 1)
      visit post_path(post)

      # 重複投票を試みる
      click_button '1'
      click_button '投票する'

      # エラーメッセージの表示を確認
      expect(page).to have_content 'この投稿には既に投票しています'
    end

    it '投票後にポイント表示が更新されること', js: true do
      # 投票前のポイント表示を確認
      within('.post-points') do
        expect(page).to have_content '0'
      end

      # 投票実行
      click_button '1'
      click_button '投票する'

      # ポイント表示の更新を確認
      within('.post-points') do
        expect(page).to have_content '1'
      end
    end
  end
end
