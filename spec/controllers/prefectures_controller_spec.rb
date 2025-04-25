require 'rails_helper'

RSpec.describe PrefecturesController, type: :controller do
  describe 'GET #show' do
    let(:prefecture) { create(:prefecture) }
    let(:user) { create(:user) }

    context '投票のある投稿が存在する場合' do
      let!(:post1) { create(:post, prefecture: prefecture) }
      let!(:post2) { create(:post, prefecture: prefecture) }
      let!(:post3) { create(:post, prefecture: prefecture) }

      before do
        # post1に5ポイント
        create(:vote, post: post1, points: 3)
        create(:vote, post: post1, points: 2)

        # post2に3ポイント
        create(:vote, post: post2, points: 3)

        # post3には投票なし
      end

      it '正常にレスポンスを返すこと' do
        get :show, params: { id: prefecture.id }
        expect(response).to be_successful
      end

      it '指定された都道府県を取得すること' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:prefecture)).to eq prefecture
      end

      it '投票のある投稿を得点順に取得すること' do
        get :show, params: { id: prefecture.id }
        posts = assigns(:posts)

        # 投票のある投稿のみが含まれていることを確認
        expect(posts).to include(post1, post2)
        expect(posts).not_to include(post3)

        # 得点順に並んでいることを確認
        total_points = posts.map { |p| p.total_points_sum.to_i }
        expect(total_points).to eq total_points.sort.reverse
      end

      it '投票のある投稿数を正しくカウントすること' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:posts_count)).to eq 2
      end

      it '総得点を正しく計算すること' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:total_points)).to eq 8  # 5 + 3 = 8ポイント
      end
    end

    context '投稿が存在しない場合' do
      it '正常にレスポンスを返すこと' do
        get :show, params: { id: prefecture.id }
        expect(response).to be_successful
      end

      it '空の投稿リストを返すこと' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:posts)).to be_empty
      end

      it '投稿数が0であること' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:posts_count)).to eq 0
      end

      it '総得点が0であること' do
        get :show, params: { id: prefecture.id }
        expect(assigns(:total_points)).to eq 0
      end
    end

    context '存在しない都道府県IDの場合' do
      it 'ActiveRecord::RecordNotFoundを発生させること' do
        expect {
          get :show, params: { id: 'nonexistent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
