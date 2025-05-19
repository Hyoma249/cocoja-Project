require 'rails_helper'

RSpec.describe PrefecturesController, type: :controller do
  describe 'GET #show' do
    let(:prefecture) { create(:prefecture) }
    let(:user) { create(:user) }

    context 'when 投票のある投稿が存在する場合' do
      let!(:high_voted_post) { create(:post, prefecture: prefecture) }
      let!(:low_voted_post) { create(:post, prefecture: prefecture) }
      let!(:no_votes_post) { create(:post, prefecture: prefecture) }

      before do
        create(:vote, post: high_voted_post, points: 3)
        create(:vote, post: high_voted_post, points: 2)
        create(:vote, post: low_voted_post, points: 3)
        get :show, params: { id: prefecture.id }
      end

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it '指定された都道府県を取得すること' do
        expect(controller.instance_variable_get(:@prefecture)).to eq prefecture
      end

      it '投票のある投稿を得点順に取得すること' do
        posts = controller.instance_variable_get(:@posts)
        expect(posts).to include(high_voted_post, low_voted_post)
        expect(posts).not_to include(no_votes_post)

        total_points = posts.map { |p| p.total_points_sum.to_i }
        expect(total_points).to eq total_points.sort.reverse
      end

      it '投票のある投稿数を正しくカウントすること' do
        expect(controller.instance_variable_get(:@posts_count)).to eq 2
      end

      it '総得点を正しく計算すること' do
        expect(controller.instance_variable_get(:@total_points)).to eq 8
      end
    end

    context 'when 投稿が存在しない場合' do
      before { get :show, params: { id: prefecture.id } }

      it '正常にレスポンスを返すこと' do
        expect(response).to be_successful
      end

      it '空の投稿リストを返すこと' do
        expect(controller.instance_variable_get(:@posts)).to be_empty
      end

      it '投稿数が0であること' do
        expect(controller.instance_variable_get(:@posts_count)).to eq 0
      end

      it '総得点が0であること' do
        expect(controller.instance_variable_get(:@total_points)).to eq 0
      end
    end

    context 'when 存在しない都道府県IDの場合' do
      it 'ActiveRecord::RecordNotFoundを発生させること' do
        expect {
          get :show, params: { id: 'nonexistent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
