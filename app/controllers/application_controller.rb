# 全てのコントローラーの基底クラス。アプリケーション全体で共通の機能を提供します。
class ApplicationController < ActionController::Base
  # 全てのコントローラーに対してユーザー認証を要求
  # 特定のアクションは各コントローラーで例外設定するのが望ましい
  before_action :authenticate_user!
  before_action :set_default_meta_tags

  def after_sign_in_path_for(_resource)
    top_page_login_url(protocol: 'https')
  end

  private

  def redirect_if_authenticated
    return unless user_signed_in?

    redirect_to top_page_login_path
  end

  def set_default_meta_tags
    # 本番環境用のホスト名を取得
    host = Rails.env.production? ? 'cocoja-7b01rrht.b4a.run' : request.host_with_port
    protocol = 'https' # 常にhttpsを使用

    # OGP画像のURL - 絶対URLで明示的に指定
    ogp_image_url = "#{protocol}://#{host}#{ActionController::Base.helpers.asset_path('cocoja-ogp.png')}"

    set_meta_tags(
      site: 'ココじゃ',
      reverse: true,
      separator: '|',
      title: 'ココじゃ｜都道府県魅力度ランキングSNS',
      description: '「ココじゃ」は、都道府県の魅力を発見・共有できる魅力度ランキングSNSです。あなたの地元や旅先の魅力を投稿して、みんなで盛り上げよう！',
      keywords: 'ココじゃ, 都道府県, 魅力度ランキング, 地域情報, SNS, 観光, 地元',
      canonical: request.original_url,
      og: {
        site_name: 'ココじゃ',
        title: :title,
        description: :description,
        type: 'website',
        url: "#{protocol}://#{host}#{request.path}",
        image: {
          _: ogp_image_url,
          width: 1200,
          height: 630
        }
      },
      twitter: {
        card: 'summary_large_image',
        site: '@cocoja_app',
        creator: '@cocoja_app',
        image: ogp_image_url
      }
    )
  end
end
