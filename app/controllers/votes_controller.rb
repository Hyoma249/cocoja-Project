class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :check_vote_permissions, only: [:create]

  def create
    @vote = current_user.votes.build(vote_params)
    @vote.post = @post

    begin
      respond_to do |format|
        if @vote.save
          format.html { redirect_to @post, notice: "#{@vote.points}ポイントを付与しました" }
          format.turbo_stream do
            flash.now[:notice] = "#{@vote.points}ポイントを付与しました"
            render turbo_stream: [
              turbo_stream.replace('vote_form', partial: 'posts/vote_form', locals: { post: @post }),
              turbo_stream.replace('flash', partial: 'shared/flash'),
              turbo_stream.replace("post_points_#{@post.id}",
                                   partial: 'posts/post_points',
                                   locals: { post: @post.reload })
            ]
          end
        else
          error_message = @vote.errors.full_messages.join(', ')
          format.html { redirect_to @post, alert: error_message }
          format.turbo_stream do
            flash.now[:alert] = error_message
            render turbo_stream: [
              turbo_stream.replace('vote_form', partial: 'posts/vote_form', locals: { post: @post }),
              turbo_stream.replace('flash', partial: 'shared/flash')
            ]
          end
        end
      end
    rescue ActiveRecord::RecordNotUnique
      respond_to do |format|
        error_message = 'この投稿にはすでにポイントを付けています'
        format.html { redirect_to @post, alert: error_message }
        format.turbo_stream do
          flash.now[:alert] = error_message
          render turbo_stream: [
            turbo_stream.replace('vote_form', partial: 'posts/vote_form', locals: { post: @post }),
            turbo_stream.replace('flash', partial: 'shared/flash')
          ]
        end
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

  def check_vote_permissions
    requested_points = params[:vote][:points].to_i
    unless current_user.can_vote?(requested_points)
      redirect_to @post, alert: "残りポイント不足です（残り#{current_user.remaining_daily_points}ポイント）"
      return
    end
  end
end
