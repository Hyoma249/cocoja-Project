require 'rails_helper'

RSpec.describe PostImage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post).counter_cache(true) }
  end

  describe 'uploader' do
    let(:post_image) { build(:post_image) }

    it 'mounts PostImageUploader' do
      expect(post_image).to respond_to(:image)
      expect(described_class.uploaders[:image]).to eq(PostImageUploader)
    end

    it 'accepts valid image files' do
      post_image = build(:post_image)
      post_image.image = fixture_file_upload(
        Rails.root.join('spec/fixtures/test_image1.jpg'),
        'image/jpeg'
      )
      expect(post_image).to be_valid
    end
  end

  describe 'counter_cache' do
    it 'updates post_images_count on post' do
      post = create(:post)
      expect do
        create(:post_image, post: post)
      end.to change { post.reload.post_images_count }.by(1)
    end
  end
end
