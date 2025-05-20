class Prefecture < ApplicationRecord
  has_many :posts, dependent: :nullify
  has_many :weekly_rankings, dependent: :destroy

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }

  scope :with_points, -> {
    joins(posts: :votes)
      .select('prefectures.*, SUM(votes.points) as total_points')
      .group('prefectures.id')
  }

  scope :with_points_between, ->(start_date, end_date) {
    left_outer_joins(posts: :votes)
      .where('votes.voted_on IS NULL OR votes.voted_on BETWEEN ? AND ?', start_date.to_date, end_date.to_date)
      .group(:id)
      .select('prefectures.*, COALESCE(SUM(votes.points), 0) as weekly_points')
  }

  def popular_posts
    posts.joins(:votes)
         .select('posts.*, SUM(votes.points) as total_points_sum')
         .group('posts.id')
         .having('SUM(votes.points) > 0')
         .order('total_points_sum DESC')
  end

  def weekly_points(start_date, end_date)
    Post.joins(:votes)
        .where(prefecture_id: id)
        .where('votes.voted_on BETWEEN ? AND ?', start_date.to_date, end_date.to_date)
        .sum('votes.points')
  end

  def current_week_points
    start_date = Time.zone.now.beginning_of_week
    end_date = Time.zone.now
    weekly_points(start_date, end_date)
  end

  def total_votes_points
    posts.joins(:votes).sum('votes.points')
  end

  def self.weekly_points_for_all(start_date, end_date)
    joins(posts: :votes)
      .where('votes.voted_on BETWEEN ? AND ?', start_date.to_date, end_date.to_date)
      .group(:id)
      .sum('votes.points')
  end
end
