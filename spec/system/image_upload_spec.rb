require 'rails_helper'

RSpec.describe '画像アップロード機能' do
  let(:user) { create(:user) }
  let(:single_image_path) { Rails.root.join('spec/fixtures/test_image1.jpg') }
  let(:additional_image_path) { Rails.root.join('spec/fixtures/test_image2.jpg') }

  before do
    # テスト用の画像ファイルを準備
    FileUtils.mkdir_p(File.dirname(single_image_path))
    [ single_image_path, additional_image_path ].each do |path|
      FileUtils.touch(path)
    end

    # Cloudinaryのモック設定
    allow(Cloudinary::Uploader).to receive(:upload).and_return({
      'public_id' => 'test_image',
      'url' => 'http://example.com/test_image.jpg'
    })

    login_as(user)
  end

  describe '投稿画像機能' do
    before do
      create(:prefecture, name: '東京都')
      visit new_post_path
    end

    it '画像付きの投稿が作成できること' do
      # 基本情報の入力
      find('select[name="post[prefecture_id]"]').find(:option, '東京都').select_option
      fill_in 'post[content]', with: 'テスト投稿です'

      # 画像の添付（1枚目）
      attach_file 'pi', single_image_path

      click_button '投稿する'

      # 投稿の確認
      expect(page).to have_content 'テスト投稿です'
      expect(Post.last.post_images.count).to eq 1
    end

    it '複数の画像を投稿できること' do
      # 基本情報の入力
      find('select[name="post[prefecture_id]"]').find(:option, '東京都').select_option
      fill_in 'post[content]', with: 'テスト投稿です'

      # 複数画像の添付
      attach_file 'pi', [ single_image_path, additional_image_path ]

      click_button '投稿する'

      # 投稿とデータベースの確認
      expect(page).to have_content 'テスト投稿です'
      expect(Post.last.post_images.count).to eq 2
    end
  end

  describe 'プロフィール画像機能' do
    it 'プロフィール画像を設定できること' do
      visit edit_mypage_path

      # プロフィール更新
      fill_in 'ユーザー名', with: user.username
      attach_file 'user[profile_image_url]', single_image_path
      click_button '保存する'

      # 更新の確認
      expect(user.reload.profile_image_url).to be_present
    end
  end
end
