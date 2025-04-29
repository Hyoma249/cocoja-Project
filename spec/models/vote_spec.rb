require 'rails_helper'

RSpec.describe Vote do
  describe 'associations' do
    subject(:vote) { described_class.new }

    it { expect(vote).to belong_to(:user) }
    it { expect(vote).to belong_to(:post) }
  end

  describe 'validations' do
    subject(:vote) { described_class.new }

    it { expect(vote).to validate_numericality_of(:points)
          .only_integer
          .is_greater_than(0)
          .is_less_than_or_equal_to(5) }

    describe 'daily_point_limit' do
      let(:user) { create(:user) }
      let(:post) { create(:post) }

      it 'allows voting within daily limit' do
        vote = build(:vote, user: user, post: post, points: 3)
        expect(vote).to be_valid
      end

      it 'prevents voting over daily limit' do
        create(:vote, user: user, points: 4)  # 既に4ポイント使用
        vote = build(:vote, user: user, post: post, points: 2)  # 2ポイント追加しようとする
        expect(vote).not_to be_valid  # 合計が6ポイントになるため無効
        expect(vote.errors[:points]).to include('1日の投票ポイント上限（5ポイント）を超えています。残り1ポイントです。')
      end
    end

    describe 'cannot_vote_own_post' do
      let(:user) { create(:user) }

      it 'prevents voting on own post' do
        post = create(:post, user: user)
        vote = build(:vote, user: user, post: post)
        expect(vote).not_to be_valid
        expect(vote.errors[:post]).to include('自分の投稿にはポイントを付けられません')
      end
    end

    describe 'has_not_already_voted_today' do
      let(:user) { create(:user) }
      let(:post) { create(:post) }

      it 'prevents voting twice on same post in same day' do
        create(:vote, user: user, post: post, points: 2)
        vote = build(:vote, user: user, post: post, points: 1)
        expect(vote).not_to be_valid
        expect(vote.errors[:post]).to include('同じ投稿に1日に複数回ポイントを付けることはできません')
      end
    end
  end

  describe 'scopes' do
    describe '.today' do
      it 'returns only votes from today' do
        user = create(:user)
        today_vote = create(:vote, created_at: Time.current)
        yesterday_vote = create(:vote, created_at: 1.day.ago)

        expect(described_class.today).to include(today_vote)
        expect(described_class.today).not_to include(yesterday_vote)
      end
    end
  end
end
