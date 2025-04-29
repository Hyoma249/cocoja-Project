require 'rails_helper'

RSpec.describe RankingsController do
  describe 'GET #index' do
    let!(:tokyo) { create(:prefecture, name: '東京都') }
    let!(:osaka) { create(:prefecture, name: '大阪府') }

    shared_context 'prefecture posts' do
      let!(:tokyo_post) { create(:post, prefecture: tokyo) }
      let!(:osaka_post) { create(:post, prefecture: osaka) }
    end

    context '現在の週のランキングが存在する場合' do
      include_context 'prefecture posts'

      let!(:top_ranking) do
        create(:weekly_ranking,
          prefecture: tokyo,
          rank: 1,
          points: 100,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i
        )
      end

      let!(:second_ranking) do
        create(:weekly_ranking,
          prefecture: osaka,
          rank: 2,
          points: 50,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i
        )
      end

      it '現在の週のランキングを取得すること' do
        get :index
        expect(assigns(:current_rankings)).to contain_exactly(top_ranking, second_ranking)
      end

      it 'ランキング順に並んでいること' do
        get :index
        expect(assigns(:current_rankings).to_a).to eq([top_ranking, second_ranking])
      end
    end

    context '現在の週のランキングが存在しない場合' do
      include_context 'prefecture posts'

      before do
        create(:vote, post: tokyo_post, points: 5, created_at: Time.zone.now)
        create(:vote, post: osaka_post, points: 3, created_at: Time.zone.now)
      end

      it 'リアルタイムでランキングを計算すること' do
        get :index
        rankings = assigns(:current_rankings)

        expect(rankings.length).to eq(2)
        expect(rankings.first.prefecture).to eq(tokyo)
        expect(rankings.first.rank).to eq(1)
        expect(rankings.second.prefecture).to eq(osaka)
        expect(rankings.second.rank).to eq(2)
      end
    end

    context '前週のランキングが存在する場合' do
      let!(:previous_ranking) do
        create(:weekly_ranking,
          prefecture: tokyo,
          rank: 1,
          points: 100,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i
        )
      end

      it '前週のランキングを取得すること' do
        get :index
        expect(assigns(:previous_rankings)).to include(previous_ranking)
      end
    end
  end
end
