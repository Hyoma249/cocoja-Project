require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:follower) { create(:user) }
  let(:followed) { create(:user) }
  let(:relationship) { create(:relationship, follower: follower, followed: followed) }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(relationship).to be_valid
    end

    it 'should require a follower_id' do
      relationship.follower_id = nil
      expect(relationship).not_to be_valid
    end

    it 'should require a followed_id' do
      relationship.followed_id = nil
      expect(relationship).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should belong to follower' do
      expect(relationship.follower).to eq(follower)
    end

    it 'should belong to followed' do
      expect(relationship.followed).to eq(followed)
    end
  end
end
