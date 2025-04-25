require 'rails_helper'

RSpec.describe PostHashtag, type: :model do
  describe 'associations' do
    it { should belong_to(:post) }
    it { should belong_to(:hashtag) }
  end

  describe 'database constraints' do
    # 存在しないpost_idでの保存を試みる
    it 'enforces foreign key constraint for post' do
      post_hashtag = build(:post_hashtag, post_id: -1)
      expect {
        post_hashtag.save!(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    # 存在しないhashtag_idでの保存を試みる
    it 'enforces foreign key constraint for hashtag' do
      post_hashtag = build(:post_hashtag, hashtag_id: -1)
      expect {
        post_hashtag.save!(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'creation' do
    # テストで使用するデータを準備
    let(:post) { create(:post) }
    let(:hashtag) { create(:hashtag) }

    it 'successfully creates a post_hashtag' do
      # PostHashtagインスタンスを生成
      post_hashtag = described_class.new(post: post, hashtag: hashtag)

      # バリデーションが通ることを確認
      expect(post_hashtag).to be_valid

      # 保存時にレコード数が1増えることを確認
      expect {
        post_hashtag.save
      }.to change(PostHashtag, :count).by(1)
    end
  end
end
