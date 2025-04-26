require 'rails_helper'

RSpec.describe '投稿機能', type: :system do
  let(:user) { create(:user) }
  let!(:prefecture) { create(:prefecture, name: '東京都') } # 具体的な都道府県名を設定

  before do
    login_as(user, scope: :user)
  end

  describe '新規投稿' do
    it '投稿を作成できること' do
      visit new_post_path

      # 投稿フォームの入力
      select '東京都', from: 'post[prefecture_id]'
      fill_in 'post[content]', with: 'テスト投稿です'
      click_button '投稿する' # ボタンのテキストを修正

      # 投稿成功の確認
      expect(page).to have_content 'テスト投稿です'
      expect(page).to have_content '東京都'
    end

    context 'エラーの場合' do
      it '投稿に失敗すること' do
        visit new_post_path
        # 何も入力せずに投稿
        click_button '投稿する'

        # フォームが表示されたままであることを確認
        expect(page).to have_selector('form')
        expect(page).to have_selector('select[name="post[prefecture_id]"]')
      end
    end
  end

  describe '投稿一覧' do
    let!(:posts) { create_list(:post, 3, user: user, prefecture: prefecture) }

    it '投稿一覧が表示されること' do
      visit posts_path
      expect(page).to have_selector('.grid')
      posts.each do |post|
        expect(page).to have_content(post.content)
      end
    end
  end
end
