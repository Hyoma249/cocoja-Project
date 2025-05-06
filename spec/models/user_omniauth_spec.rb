require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    # テスト用の認証ハッシュ
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          name: 'Test User',
          image: 'https://example.com/test_image.jpg'
        }
      )
    end

    context '新規ユーザーの場合' do
      it 'Googleの情報から新規ユーザーを作成する' do
        expect {
          User.from_omniauth(auth_hash)
        }.to change(User, :count).by(1)

        # 作成されたユーザーの情報を確認
        user = User.last
        expect(user.email).to eq('test@example.com')
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid_from_provider).to eq('123456789')
      end
    end

    context '既存ユーザーの場合' do
      # 事前にユーザーを作成
      let!(:existing_user) do
        User.create!(
          email: 'test@example.com',
          password: 'password',
          provider: 'google_oauth2',
          uid_from_provider: '123456789',
          username: 'testuser'
        )
      end

      it '既存ユーザーを返し、新規作成しない' do
        expect {
          result = User.from_omniauth(auth_hash)
          expect(result).to eq(existing_user)
        }.not_to change(User, :count)
      end
    end
  end
end
