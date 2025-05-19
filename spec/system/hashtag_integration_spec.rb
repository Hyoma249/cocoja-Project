require 'rails_helper'

RSpec.describe 'ハッシュタグ機能', type: :system do
  let(:user) { create(:user) }
  let!(:prefecture) { create(:prefecture, name: '東京都') }

  before do
    sign_in user
    driven_by(:rack_test)
  end

  describe 'ハッシュタグの機能' do
    context 'when 新規投稿を作成する場合' do
      it '投稿が保存され、ハッシュタグが作成されること' do
        visit new_post_path
        select prefecture.name, from: 'post[prefecture_id]'
        fill_in 'post[content]', with: 'テスト投稿です #観光 #グルメ'
        click_button '投稿する'

        post = Post.last
        expect(post.hashtags.pluck(:name)).to contain_exactly('観光', 'グルメ')
      end

      it '投稿詳細でハッシュタグが表示されること' do
        post = create(:post, user: user, prefecture: prefecture, content: 'テスト投稿です #観光 #グルメ')
        visit post_path(post)

        expect(page).to have_content 'テスト投稿です'
        expect(page).to have_content '#観光'
        expect(page).to have_content '#グルメ'
      end
    end

    context 'when ハッシュタグで検索する場合' do
      before do
        create(:post,
          user: user,
          prefecture: prefecture,
          content: '観光スポット #観光')

        create(:post,
          user: user,
          prefecture: prefecture,
          content: 'ランチ #グルメ')
      end

      it 'ハッシュタグページで関連投稿のみが表示されること' do
        tag = Hashtag.find_by(name: '観光')
        visit hashtag_posts_path(name: tag.name)

        expect(page).to have_content '観光スポット'
        expect(page).not_to have_content 'ランチ'
      end

      it '投稿一覧から特定のハッシュタグで絞り込みができること' do
        visit posts_path
        expect(page).to have_content '観光スポット'

        tag = Hashtag.find_by(name: '観光')
        visit hashtag_posts_path(name: tag.name)

        expect(page).to have_content '観光スポット'
        expect(page).to have_content 'ハッシュタグ「#観光」の投稿'
      end
    end
  end
end
