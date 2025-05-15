class AddCreatedAtPointsIndexToVotes < ActiveRecord::Migration[7.1]
  def change
    add_index :votes, [:created_at, :points], name: 'index_votes_on_created_at_and_points'
  end
end
