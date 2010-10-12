class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_theme_cookie

  def get_theme_cookie
    @theme = cookies['dubsar_theme'] || default_theme
  end

  def default_theme
    'light'
  end
end
