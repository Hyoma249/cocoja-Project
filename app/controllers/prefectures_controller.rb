class PrefecturesController < ApplicationController
  def show
    @prefecture = Prefecture.find(params[:id])

    @posts = @prefecture.posts.joins(:votes)
            .select("posts.*, SUM(votes.points) as total_points_sum")
            .group("posts.id")
            .having("SUM(votes.points) > 0")
            .order("total_points_sum DESC")

    @posts_count = @posts.length
    @total_points = @prefecture.posts.joins(:votes).sum("votes.points")
  end
end
