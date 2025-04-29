require 'rails_helper'

RSpec.describe '投稿機能' do
  let(:user) { create(:user) }
  let!(:prefecture) { create(:prefecture, name: '東京都') } # 固定の都道府県名を設定
  let!(:prefectures) { create_list(:prefecture, 46) } # その他の都道府県も作成

  describe '新規投稿' do
    before do
      login_as(user, scope: :user)
      visit new_post_path
    end

    context '正常な値の場合' do
      it '投稿の作成に成功すること' do
        # プロンプトテキストを確認してから選択
        expect(page).to have_select('post[prefecture_id]', with_options: [ '東京都' ])
        select '東京都', from: 'post[prefecture_id]'
        fill_in 'post[content]', with: 'テスト投稿です'
        click_button '投稿する'

        # 投稿成功の確認
        expect(page).to have_content 'テスト投稿です'
      end
    end

    context '無効な値の場合' do
      it '必須項目が未入力の場合、エラーになること' do
        click_button '投稿する'

        # エラーメッセージの確認（実際の表示に合わせる）
        expect(page).to have_content '投稿の作成に失敗しました'
        # エラーメッセージの表示を確認（フラッシュメッセージ）
        within('.fixed.top-4') do
          expect(page).to have_content '投稿の作成に失敗しました'
        end
      end
    end
  end

  describe '投稿一覧' do
    let!(:posts) { create_list(:post, 3, user: user, prefecture: prefecture) }

    before do
      login_as(user, scope: :user)
      visit posts_path
    end

    it '投稿一覧が表示されること' do
      # 各投稿の内容が表示されていることを確認
      posts.each do |post|
        expect(page).to have_content post.content
      end
    end
  end

  describe '投稿詳細' do
    let!(:post) { create(:post, user: user, prefecture: prefecture) }

    before do
      login_as(user, scope: :user)
      visit post_path(post)
    end

    it '投稿の詳細情報が表示されること' do
      # 必要最小限の要素の確認
      expect(page).to have_content post.content
      expect(page).to have_content user.uid
    end
  end
end
