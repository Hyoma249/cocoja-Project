class VotesController < ApplicationController
  # ログインしていない人は投票できないようにします（ログインしてなかったらログインページに飛ばされるよ）
  before_action :authenticate_user!
  # 投票する対象の「投稿（Post）」をデータベースから取り出しておく
  before_action :set_post

  def create
    # 「今ログインしてるユーザー」が「投票」データを新しく作る
    @vote = current_user.votes.build(vote_params)
    # 投票対象の「投稿」をセットします
    @vote.post = @post

    respond_to do |format|
      if @vote.save
        format.html { redirect_to @post, notice: "#{@vote.points}ポイントを付与しました" }
        format.turbo_stream {
          flash.now[:notice] = "#{@vote.points}ポイントを付与しました"
          render turbo_stream: [
            turbo_stream.replace("vote_form", partial: "posts/vote_form", locals: { post: @post }),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        }
      else
        format.html { redirect_to @post, alert: @vote.errors.full_messages.join(", ") }
        format.turbo_stream {
          flash.now[:alert] = @vote.errors.full_messages.join(", ")
          render turbo_stream: [
            turbo_stream.replace("vote_form", partial: "posts/vote_form", locals: { post: @post }),
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        }
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
end