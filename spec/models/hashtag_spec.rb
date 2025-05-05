# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hashtag, type: :model do
  describe 'バリデーション' do
    it 'nameがあれば有効であること' do
      hashtag = build(:hashtag, name: 'test')
      expect(hashtag).to be_valid
    end

    it 'nameがなければ無効であること' do
      hashtag = build(:hashtag, name: nil)
      expect(hashtag).not_to be_valid
    end

    it '同じnameのハッシュタグは作成できないこと' do
      create(:hashtag, name: 'test')
      duplicate_hashtag = build(:hashtag, name: 'test')
      expect(duplicate_hashtag).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'post_hashtagsを通じて複数の投稿を持つこと' do
      hashtag = create(:hashtag)
      post1 = create(:post)
      post2 = create(:post)

      create(:post_hashtag, post: post1, hashtag: hashtag)
      create(:post_hashtag, post: post2, hashtag: hashtag)

      expect(hashtag.posts.count).to eq 2
    end
  end
end
