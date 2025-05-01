# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostHashtag, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:hashtag) }
  end

  describe 'database constraints' do
    it 'enforces foreign key constraint for post' do
      post_hashtag = build(:post_hashtag, post_id: -1)
      expect {
        post_hashtag.save!(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'enforces foreign key constraint for hashtag' do
      post_hashtag = build(:post_hashtag, hashtag_id: -1)
      expect {
        post_hashtag.save!(validate: false)
      }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'creation' do
    let(:post) { create(:post) }
    let(:hashtag) { create(:hashtag) }

    it 'successfully creates a post_hashtag' do
      post_hashtag = described_class.new(post: post, hashtag: hashtag)
      expect(post_hashtag).to be_valid
      expect { post_hashtag.save }.to change(described_class, :count).by(1)
    end
  end
end
