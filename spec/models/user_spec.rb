# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    context 'when on update' do
      subject { create(:user) }

      it { is_expected.to validate_presence_of(:username).on(:update) }
      it { is_expected.to validate_length_of(:username).is_at_least(1).is_at_most(20).on(:update) }
      it { is_expected.to validate_uniqueness_of(:username).on(:update) }

      it { is_expected.to validate_presence_of(:uid).on(:update) }
      it { is_expected.to validate_length_of(:uid).is_at_least(6).is_at_most(15).on(:update) }
      it { is_expected.to validate_uniqueness_of(:uid).on(:update) }

      it { is_expected.to validate_length_of(:bio).is_at_most(160) }
      it { is_expected.to allow_value('').for(:bio) }
      it { is_expected.to allow_value(nil).for(:bio) }

      it 'validates uid format' do
        user = create(:user)

        # 正常系のテスト
        user.uid = 'abc123'
        expect(user).to be_valid

        # 異常系のテスト
        user.uid = 'abc-123'
        expect(user).not_to be_valid
        expect(user.errors[:uid]).to include('は半角英数字のみ使用できます')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:votes).dependent(:destroy) }
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#daily_votes_count' do
      it 'returns sum of today votes points' do
        travel_to(1.day.ago) do
          create(:vote, user: user, points: 1)
        end

        freeze_time do
          create(:vote, user: user, points: 2)
          create(:vote, user: user, points: 3)
        end

        expect(user.daily_votes_count).to eq(5) # 今日の投票（2+3=5）のみカウント
      end
    end

    describe '#remaining_daily_points' do
      it 'returns remaining points for today' do
        create(:vote, user: user, points: 2, created_at: Time.current)
        expect(user.remaining_daily_points).to eq(3) # 5 - 2 = 3ポイント残り
      end

      it 'returns 0 when used all points' do
        create(:vote, user: user, points: 5, created_at: Time.current)

        expect(user.remaining_daily_points).to eq(0) # ポイントを使い切った
      end
    end

    describe '#can_vote?' do
      it 'returns true when enough points remain' do
        create(:vote, user: user, points: 2, created_at: Time.current)

        expect(user.can_vote?(3)).to be true # 2ポイント使用済み→3ポイント追加OK
      end

      it 'returns false when not enough points remain' do
        create(:vote, user: user, points: 4, created_at: Time.current)

        expect(user.can_vote?(2)).to be false # 4ポイント使用済み→2ポイント追加NG
      end
    end
  end
end
