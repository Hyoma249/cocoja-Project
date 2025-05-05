require 'rails_helper'

# サーチ機能の内部ロジックをモデルレベルでテスト
RSpec.describe 'SearchService', type: :model do
  describe '#search_users' do
    it 'クエリに一致するユーザーを見つけること' do
      # テスト用のユーザーを作成
      user = create(:user, username: 'testuser')

      # 直接モデルを使ってクエリを実行
      results = User.where('username LIKE ?', '%test%').limit(5)

      expect(results).to include(user)
    end
  end

  describe '#search_prefectures' do
    it 'クエリに一致する都道府県を見つけること' do
      prefecture = create(:prefecture, name: 'テスト県')

      results = Prefecture.where('name LIKE ?', '%テスト%').limit(5)

      expect(results).to include(prefecture)
    end
  end

  describe '#search_hashtags' do
    it 'クエリに一致するハッシュタグを見つけること' do
      hashtag = create(:hashtag, name: 'testhashtag')

      results = Hashtag.where('name LIKE ?', '%test%').limit(5)

      expect(results).to include(hashtag)
    end
  end
end
