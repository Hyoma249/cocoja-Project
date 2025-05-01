# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RankingsController, type: :controller do
  describe 'GET #index' do
    let(:tokyo) { create(:prefecture, name: '東京都') }
    let(:osaka) { create(:prefecture, name: '大阪府') }

    context 'when 現在の週のランキングが存在する場合' do
      let!(:top_ranking) do
        create(:weekly_ranking,
          prefecture: tokyo,
          rank: 1,
          points: 100,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i)
      end
      let!(:second_ranking) do
        create(:weekly_ranking,
          prefecture: osaka,
          rank: 2,
          points: 50,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i)
      end

      before { get :index }

      it '現在の週のランキングを取得すること' do
        expect(controller.instance_variable_get(:@current_rankings))
          .to contain_exactly(top_ranking, second_ranking)
      end

      it 'ランキング順に並んでいること' do
        rankings = controller.instance_variable_get(:@current_rankings)
        expect(rankings.to_a).to eq([top_ranking, second_ranking])
      end
    end

    context 'when 現在の週のランキングが存在しない場合' do
      let(:tokyo_post) { create(:post, prefecture: tokyo) }
      let(:osaka_post) { create(:post, prefecture: osaka) }

      before do
        create(:vote, post: tokyo_post, points: 5, created_at: Time.zone.now)
        create(:vote, post: osaka_post, points: 3, created_at: Time.zone.now)
        get :index
      end

      it 'リアルタイムでランキングを正しく計算すること' do
        rankings = controller.instance_variable_get(:@current_rankings)
        expect(rankings.length).to eq(2)
        expect(rankings.first.prefecture).to eq(tokyo)
      end

      it 'ランキングの順位が正しく設定されていること' do
        rankings = controller.instance_variable_get(:@current_rankings)
        expect(rankings.first.rank).to eq(1)
        expect(rankings.second.rank).to eq(2)
      end
    end

    context 'when 前週のランキングが存在する場合' do
      let!(:previous_ranking) do
        create(:weekly_ranking,
          prefecture: tokyo,
          rank: 1,
          points: 100,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i)
      end

      before { get :index }

      it '前週のランキングを取得すること' do
        expect(controller.instance_variable_get(:@previous_rankings))
          .to include(previous_ranking)
      end
    end
  end
end
