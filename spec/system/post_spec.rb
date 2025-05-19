require 'rails_helper'

RSpec.describe '投稿機能', type: :system do
  let(:user) { create(:user) }
  let!(:prefecture) { create(:prefecture, name: '東京都') }

  describe '新規投稿' do
    before do
      sign_in user
      driven_by(:rack_test)
      visit new_post_path
    end

    context 'when 正常な値の場合' do
      it '投稿の作成に成功すること' do
        expect(page).to have_select('post[prefecture_id]', with_options: ['東京都'])
        select '東京都', from: 'post[prefecture_id]'
        fill_in 'post[content]', with: 'テスト投稿です'
        click_button '投稿する'

        expect(page).to have_content 'テスト投稿です'
      end
    end

    context 'when 無効な値の場合' do
      it '必須項目が未入力の場合、エラーになること' do
        click_button '投稿する'

        expect(page).to have_content 'Prefectureを入力してください'
        expect(page).to have_content 'Prefectureを入力してください'
      end
    end
  end

  describe '投稿一覧' do
    let!(:posts) { create_list(:post, 3, user: user, prefecture: prefecture) }

    before do
      sign_in user
      driven_by(:rack_test)
      visit posts_path
    end

    it '投稿一覧が表示されること' do
      posts.each do |post|
        expect(page).to have_content post.content
      end
    end
  end

  describe '投稿詳細' do
    let!(:post) { create(:post, user: user, prefecture: prefecture) }

    before do
      sign_in user
      driven_by(:rack_test)
      visit post_path(post)
    end

    it '投稿の詳細情報が表示されること' do
      expect(page).to have_content post.content
      expect(page).to have_content user.uid
    end
  end
end
