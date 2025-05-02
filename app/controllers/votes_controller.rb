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
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def vote_params
    params.require(:vote).permit(:points)
  end

  def build_vote
    vote = current_user.votes.build(vote_params)
    vote.post = @post
    vote
  end

  def handle_successful_vote(format)
    success_message = t('controllers.votes.create.success', points: @vote.points)

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
