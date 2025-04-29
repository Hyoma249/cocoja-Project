require 'rails_helper'

RSpec.describe Hashtag do
  describe 'associations' do
    it { is_expected.to have_many(:post_hashtags) }
    it { is_expected.to have_many(:posts).through(:post_hashtags) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:name).is_at_most(99) }

    context 'when creating hashtags' do
      it 'allows valid hashtag names' do
        valid_names = [ 'rails', 'ruby123', '東京', 'ruby_on_rails' ]
        valid_names.each do |name|
          hashtag = build(:hashtag, name: name)
          expect(hashtag).to be_valid
        end
      end

      it 'creates lowercase hashtags' do
        hashtag = create(:hashtag, name: 'RAILS')
        expect(hashtag.name).to eq('rails')
      end

      it 'prevents duplicate hashtags' do
        create(:hashtag, name: 'ruby')
        duplicate_hashtag = build(:hashtag, name: 'ruby')
        expect(duplicate_hashtag).not_to be_valid
      end
    end
  end

  describe 'scopes and methods' do
    let!(:hashtag) { create(:hashtag) }
    let!(:posts) { create_list(:post, 3) }

    before do
      posts.each do |post|
        create(:post_hashtag, post: post, hashtag: hashtag)
      end
    end

    it 'retrieves associated posts' do
      expect(hashtag.posts).to match_array(posts)
    end
  end
end
