require 'rails_helper'

RSpec.describe WeeklyRanking, type: :model do
  describe 'associations' do
    it { should belong_to(:prefecture) }
  end

  describe 'validations' do
    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:week) }
    it { should validate_presence_of(:rank) }
    it { should validate_presence_of(:points) }
  end

  describe 'scopes' do
    let!(:current_ranking) do
      create(:weekly_ranking,
        year: Time.current.year,
        week: Time.current.strftime('%U').to_i
      )
    end

    let!(:previous_ranking) do
      create(:weekly_ranking,
        year: 1.week.ago.year,
        week: 1.week.ago.strftime('%U').to_i
      )
    end

    let!(:old_ranking) do
      create(:weekly_ranking,
        year: 2.weeks.ago.year,
        week: 2.weeks.ago.strftime('%U').to_i
      )
    end

    describe '.current_week' do
      it 'returns rankings from current week' do
        expect(WeeklyRanking.current_week).to include(current_ranking)
        expect(WeeklyRanking.current_week).not_to include(previous_ranking)
        expect(WeeklyRanking.current_week).not_to include(old_ranking)
      end
    end

    describe '.previous_week' do
      it 'returns rankings from previous week' do
        expect(WeeklyRanking.previous_week).to include(previous_ranking)
        expect(WeeklyRanking.previous_week).not_to include(current_ranking)
        expect(WeeklyRanking.previous_week).not_to include(old_ranking)
      end
    end
  end

  describe '#rank_change_from_previous' do
    let(:prefecture) { create(:prefecture) }

    context 'when previous ranking exists' do
      it 'returns positive value when rank improved' do
        create(:weekly_ranking,
          prefecture: prefecture,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i,
          rank: 5
        )
        current = create(:weekly_ranking,
          prefecture: prefecture,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i,
          rank: 3
        )

        expect(current.rank_change_from_previous).to eq(2) # 5 - 3 = 2（2位上昇）
      end

      it 'returns negative value when rank declined' do
        create(:weekly_ranking,
          prefecture: prefecture,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i,
          rank: 3
        )
        current = create(:weekly_ranking,
          prefecture: prefecture,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i,
          rank: 5
        )

        expect(current.rank_change_from_previous).to eq(-2) # 3 - 5 = -2（2位下降）
      end
    end

    context 'when previous ranking does not exist' do
      it 'returns nil' do
        current = create(:weekly_ranking,
          prefecture: prefecture,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i
        )

        expect(current.rank_change_from_previous).to be_nil
      end
    end
  end
end
