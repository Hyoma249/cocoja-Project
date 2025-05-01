# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:follower_user) { create(:user) }
  let(:followed_user) { create(:user) }
  let(:relationship) { build(:relationship, follower: follower_user, followed: followed_user) }

  describe 'バリデーション' do
    it '有効なファクトリを持つこと' do
      expect(relationship).to be_valid
    end

    it 'follower_idがnilの場合は無効であること' do
      relationship.follower_id = nil
      expect(relationship).not_to be_valid
    end

    it 'followed_idがnilの場合は無効であること' do
      relationship.followed_id = nil
      expect(relationship).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'フォローしているユーザーと関連付けられていること' do
      expect(relationship.follower).to eq follower_user
    end

    it 'フォローされているユーザーと関連付けられていること' do
      expect(relationship.followed).to eq followed_user
    end
  end
end
