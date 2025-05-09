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
    # 完全に固定のOGP情報を設定
    set_meta_tags(
      site: 'ココじゃ',
      reverse: true,
      separator: '|',
      title: 'ココじゃ｜都道府県魅力度ランキングSNS',
      description: '「ココじゃ」は、都道府県の魅力を発見・共有できる魅力度ランキングSNSです。あなたの地元や旅先の魅力を投稿して、みんなで盛り上げよう！',
      keywords: 'ココじゃ, 都道府県, 魅力度ランキング, 地域情報, SNS, 観光, 地元',
      og: {
        site_name: 'ココじゃ',
        title: 'ココじゃ | 都道府県魅力度ランキングSNS',
        description: '「ココじゃ」は、都道府県の魅力を発見・共有できる魅力度ランキングSNSです。あなたの地元や旅先の魅力を投稿して、みんなで盛り上げよう！',
        type: 'website',
        url: 'https://cocoja-7b01rrht.b4a.run/',
        image: 'https://cocoja-7b01rrht.b4a.run/cocoja-ogp.png'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@cocoja_app',
        title: 'ココじゃ | 都道府県魅力度ランキングSNS',
        description: '「ココじゃ」は、都道府県の魅力を発見・共有できる魅力度ランキングSNSです。あなたの地元や旅先の魅力を投稿して、みんなで盛り上げよう！',
        image: 'https://cocoja-7b01rrht.b4a.run/cocoja-ogp.png'
      }
    )
  end
end
