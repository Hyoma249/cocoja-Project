require 'rails_helper'

RSpec.describe Prefecture, type: :model do

  describe 'associations' do
    it { should have_many(:posts) }
    it { should have_many(:weekly_rankings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    subject { Prefecture.new(name: "Tokyo") }  # 英字を含む名前を使用
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'methods' do
    let(:prefecture) { create(:prefecture) }
    let(:user) { create(:user) }

    describe '#weekly_points' do
      let!(:post) { create(:post, prefecture: prefecture) }

      it 'calculates total points within date range' do
        # 指定期間内の投票を作成
        travel_to(Time.current.beginning_of_week) do
          create(:vote, post: post, points: 3)
          create(:vote, post: post, points: 2)
        end

        # 期間外の投票を作成
        travel_to(1.week.ago) do
          create(:vote, post: post, points: 5)
        end

        start_date = Time.current.beginning_of_week
        end_date = Time.current

        # 期間内の投票ポイントの合計のみカウント（3 + 2 = 5）
        expect(prefecture.weekly_points(start_date, end_date)).to eq(5)
      end
    end

    describe '#current_week_points' do
      let!(:post) { create(:post, prefecture: prefecture) }

      it 'returns total points for current week' do
        # 今週の投票を作成
        travel_to(Time.current) do
          create(:vote, post: post, points: 2)
          create(:vote, post: post, points: 3)
        end

        # 先週の投票を作成
        travel_to(1.week.ago) do
          create(:vote, post: post, points: 4)
        end

        # 今週の投票ポイントの合計のみカウント（2 + 3 = 5）
        expect(prefecture.current_week_points).to eq(5)
      end
    end
  end
end
