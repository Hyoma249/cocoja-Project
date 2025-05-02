# 設定（Settings）に関する操作を担当するコントローラー
# ユーザー設定の表示や編集機能を提供します
class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index; end
end
