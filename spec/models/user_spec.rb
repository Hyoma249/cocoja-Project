# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    # 既存のメールアドレスのバリデーション
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    context 'on update' do
      # createを使用して永続化されたユーザーを作成
      subject { create(:user) }
      # usernameのバリデーション
      it { should validate_presence_of(:username).on(:update) }
      it { should validate_length_of(:username).is_at_least(1).is_at_most(20).on(:update) }
      it { should validate_uniqueness_of(:username).on(:update) }

      # uidのバリデーション
      it { should validate_presence_of(:uid).on(:update) }
      it { should validate_length_of(:uid).is_at_least(6).is_at_most(15).on(:update) }
      it { should validate_uniqueness_of(:uid).on(:update) }

      it 'validates uid format' do
        # 一度保存されたユーザーを使用
        user = create(:user)

        # 正常系のテスト
        user.uid = 'abc123'
        expect(user).to be_valid

        # 異常系のテスト
        user.uid = 'abc-123'
        expect(user).not_to be_valid
        expect(user.errors[:uid]).to include('は半角英数字のみ使用できます')

        # 追加のテストケース
        user.uid = 'abc_123'  # アンダースコアも不可
        expect(user).not_to be_valid

        user.uid = 'あいうえお'  # 日本語は不可
        expect(user).not_to be_valid

        user.uid = '123456'   # 数字のみは可
        expect(user).to be_valid
      end

      # bioのバリデーション
      it { should validate_length_of(:bio).is_at_most(160) }
      it { should allow_value('').for(:bio) }
      it { should allow_value(nil).for(:bio) }
    end
  end

  describe 'associations' do
    # postsとの関連付けテスト
    it { should have_many(:posts).dependent(:destroy) }
    
    # votesとの関連付けテスト
    it { should have_many(:votes).dependent(:destroy) }
  end
end
