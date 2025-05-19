class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:guide]

  def guide; end
end
