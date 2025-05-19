require 'rails_helper'

RSpec.describe Prefecture, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:weekly_rankings).dependent(:destroy) }
  end

  describe 'validations' do
    subject(:prefecture) { build(:prefecture) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'methods' do
    let(:prefecture) { create(:prefecture) }

    describe '#weekly_points' do
      let!(:post) { create(:post, prefecture: prefecture) }

      it 'calculates total points within date range' do
        travel_to(Time.current.beginning_of_week) do
          create(:vote, post: post, points: 3)
          create(:vote, post: post, points: 2)
        end

        travel_to(1.week.ago) do
          create(:vote, post: post, points: 5)
        end

        start_date = Time.current.beginning_of_week
        end_date = Time.current

        expect(prefecture.weekly_points(start_date, end_date)).to eq(5)
      end
    end

    describe '#current_week_points' do
      let!(:post) { create(:post, prefecture: prefecture) }

      it 'returns total points for current week' do
        freeze_time do
          create(:vote, post: post, points: 2)
          create(:vote, post: post, points: 3)
        end

        travel_to(1.week.ago) do
          create(:vote, post: post, points: 4)
        end

        expect(prefecture.current_week_points).to eq(5)
      end
    end
  end
end
