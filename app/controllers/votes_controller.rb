# 投票（Vote）に関する操作を担当するコントローラー
# ユーザーによる投稿へのポイント付与機能を提供します
class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @vote = build_vote

    respond_to do |format|
      if @vote.save
        handle_successful_vote(format)
      else
        handle_failed_vote(format)
      end
    end
  rescue ActiveRecord::RecordNotUnique => e
    # ユーザーにエラーメッセージを表示
    error_message = "この投稿にはすでに投票済みです"

    respond_to do |format|
      format.html { redirect_to @post, alert: error_message }
      format.turbo_stream do
        flash.now[:alert] = error_message
        render_turbo_stream_response
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def vote_params
    params.require(:vote).permit(:points)
  end

  def build_vote
    # 既存の投票を探し、なければ新規作成
    vote = current_user.votes.find_or_initialize_by(post_id: @post.id)
    # 新しいポイント値を設定
    vote.points = vote_params[:points]
    vote
  end

  def handle_successful_vote(format)
    success_message = t('controllers.votes.create.success', points: @vote.points)

    # ユーザーと投稿を再読み込みして最新の状態を取得
    @post.reload
    current_user.reload

    format.html { redirect_to @post, notice: success_message }
    format.turbo_stream do
      flash.now[:notice] = success_message
      render_turbo_stream_response
    end
  end

  def handle_failed_vote(format)
    error_message = @vote.errors.full_messages.join(', ')

    format.html { redirect_to @post, alert: error_message }
    format.turbo_stream do
      flash.now[:alert] = error_message
      render_turbo_stream_response
    end
  end

  def render_turbo_stream_response
    render turbo_stream: [
      turbo_stream.replace('vote_form', partial: 'posts/vote_form', locals: { post: @post }),
      turbo_stream.replace('flash', partial: 'shared/flash')
    ]
  end
end
