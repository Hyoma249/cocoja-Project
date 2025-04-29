require 'rails_helper'

RSpec.describe 'ハッシュタグ機能' do
  let(:user) { create(:user) }
  let!(:prefecture) { create(:prefecture, name: '東京都') }

  before do
    login_as(user)
  end

  describe 'ハッシュタグの機能' do
    context '投稿作成時' do
      it '日本語のハッシュタグを含む投稿が作成できること' do
        visit new_post_path
        select prefecture.name, from: 'post[prefecture_id]'
        fill_in 'post[content]', with: 'テスト投稿です #観光 #グルメ'
        click_button '投稿する'

        # 投稿の保存を確認
        post = Post.last
        expect(post.hashtags.pluck(:name)).to contain_exactly('観光', 'グルメ')

        # 投稿詳細で表示を確認
        visit post_path(post)
        expect(page).to have_content 'テスト投稿です'
        expect(page).to have_content '#観光'
        expect(page).to have_content '#グルメ'
      end
    end

    context '検索機能' do
      before do
        # テスト用の投稿とハッシュタグを作成
        @post1 = create(:post,
          user: user,
          prefecture: prefecture,
          content: '観光スポット #観光'
        )

        @post2 = create(:post,
          user: user,
          prefecture: prefecture,
          content: 'ランチ #グルメ'
        )
      end

      it 'ハッシュタグページで関連投稿が表示されること' do
        # ハッシュタグページに直接アクセス
        tag = Hashtag.find_by(name: '観光')
        visit hashtag_posts_path(name: tag.name)

        # 投稿の表示を確認
        expect(page).to have_content '観光スポット'
        expect(page).not_to have_content 'ランチ'
      end

      it 'ハッシュタグによる投稿の絞り込みができること' do
        # 投稿一覧ページを表示
        visit posts_path
        expect(page).to have_content '観光スポット'
        expect(page).to have_content 'ランチ'

        # 「観光」のハッシュタグで絞り込み
        tag = Hashtag.find_by(name: '観光')
        visit hashtag_posts_path(name: tag.name)

        # 絞り込み結果を確認
        expect(page).to have_content '観光スポット'
        expect(page).not_to have_content 'ランチ'

        # ページタイトルも確認
        expect(page).to have_content 'ハッシュタグ「#観光」の投稿'
      end
    end
  end
end
