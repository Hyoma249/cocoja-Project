class AddProfileImageUrlToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :profile_image_url, :string
  end
end
