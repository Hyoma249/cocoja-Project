# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyRanking, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:prefecture) }
  end

  describe 'validations' do
    subject(:weekly_ranking) { build(:weekly_ranking) }

    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:week) }
    it { is_expected.to validate_presence_of(:rank) }
    it { is_expected.to validate_presence_of(:points) }
  end

  describe 'scopes' do
    let!(:current_ranking) do
      create(:weekly_ranking,
        year: Time.current.year,
        week: Time.current.strftime('%U').to_i)
    end

    let!(:previous_ranking) do
      create(:weekly_ranking,
        year: 1.week.ago.year,
        week: 1.week.ago.strftime('%U').to_i)
    end

    let!(:old_ranking) do
      create(:weekly_ranking,
        year: 2.weeks.ago.year,
        week: 2.weeks.ago.strftime('%U').to_i)
    end

    describe '.current_week' do
      it 'returns rankings from current week' do
        expect(described_class.current_week).to include(current_ranking)
        expect(described_class.current_week).not_to include(previous_ranking)
        expect(described_class.current_week).not_to include(old_ranking)
      end
    end

    describe '.previous_week' do
      it 'returns rankings from previous week' do
        expect(described_class.previous_week).to include(previous_ranking)
        expect(described_class.previous_week).not_to include(current_ranking)
        expect(described_class.previous_week).not_to include(old_ranking)
      end
    end
  end

  describe '#rank_change_from_previous' do
    let(:prefecture) { create(:prefecture) }

    context 'when previous ranking exists' do
      let(:previous_rank) { 5 }
      let(:current_rank) { 3 }

      before do
        create(:weekly_ranking,
          prefecture: prefecture,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i,
          rank: previous_rank)
      end

      it 'calculates rank improvement correctly' do
        current = create(:weekly_ranking,
          prefecture: prefecture,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i,
          rank: current_rank)

        expect(current.rank_change_from_previous).to eq(2)
      end

      context 'when rank declines' do
        let(:current_ranking) do
          described_class.destroy_all

          create(:weekly_ranking,
            prefecture: prefecture,
            year: 1.week.ago.year,
            week: 1.week.ago.strftime('%U').to_i,
            rank: 3)

          create(:weekly_ranking,
            prefecture: prefecture,
            year: Time.current.year,
            week: Time.current.strftime('%U').to_i,
            rank: 5)
        end

        it 'returns negative rank change' do
          expect(current_ranking.rank_change_from_previous).to eq(-2)
        end
      end
    end

    context 'when previous ranking does not exist' do
      it 'returns nil' do
        current = create(:weekly_ranking,
          prefecture: prefecture,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i)

        expect(current.rank_change_from_previous).to be_nil
      end
    end
  end
end
