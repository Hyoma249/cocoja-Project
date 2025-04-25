require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { should belong_to(:prefecture) }
    it { should belong_to(:user) }
    it { should have_many(:post_hashtags) }
    it { should have_many(:hashtags).through(:post_hashtags) }
    it { should have_many(:votes).dependent(:destroy) }
    it { should have_many(:post_images).dependent(:destroy) }
    it { should accept_nested_attributes_for(:post_images).allow_destroy(true) }
  end

  describe 'validations' do
    describe 'post_images_count_within_limit' do
      let(:post) { build(:post) }

      it 'is valid when post has 10 or fewer images' do
        10.times { post.post_images.build(image: 'test.jpg') }
        expect(post).to be_valid
      end

      it 'is invalid when post has more than 10 images' do
        11.times { post.post_images.build(image: 'test.jpg') }
        expect(post).not_to be_valid
        expect(post.errors[:post_images]).to include('は10枚まで投稿できます')
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates hashtags from content' do
        post = create(:post, content: '今日は#Rails と #Ruby を勉強した！')

        expect(post.hashtags.count).to eq(2)
        expect(post.hashtags.pluck(:name)).to contain_exactly('rails', 'ruby')
      end

      it 'handles Japanese hashtags' do
        post = create(:post, content: '#東京 と #大阪 に行きました！')

        expect(post.hashtags.count).to eq(2)
        expect(post.hashtags.pluck(:name)).to contain_exactly('東京', '大阪')
      end

      it 'creates unique hashtags only' do
        post = create(:post, content: '#Rails #rails #RAILS')

        expect(post.hashtags.count).to eq(1)
        expect(post.hashtags.first.name).to eq('rails')
      end
    end
  end

  describe '#total_points' do
    let(:post) { create(:post) }

    it 'calculates total points from votes' do
      create(:vote, post: post, points: 2)
      create(:vote, post: post, points: 3)

      expect(post.total_points).to eq(5)
    end

    it 'returns 0 when no votes exist' do
      expect(post.total_points).to eq(0)
    end
  end

  describe '#created_at_formatted' do
    it 'returns formatted date string' do
      post = create(:post, created_at: Time.zone.local(2024, 1, 15))
      expect(post.created_at_formatted).to eq('2024年01月15日')
    end
  end
end
