#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :get_theme_cookie
  before_filter :set_back

  respond_to :html, :json

  # Retrieve the user's <tt>dubsar_theme</tt> cookie before rendering
  # any view.
  def get_theme_cookie
    @theme = cookies['dubsar_theme'] || default_theme
  end

  def default_theme
    'light'
  end

  def redirect_with_error(errmsg)
    flash[:error] = errmsg
    redirect_to redirect_target
  end

  def redirect_with_info(infomsg)
    flash[:notice] = infomsg
    redirect_to redirect_target
  end

  def redirect_target
    params[:back] == 'yes' ? :back : :root
  end

  def error
    render :file => "#{::Rails.root}/public/404.html", :status => 404
  end

  def m_error
    render :file => "#{::Rails.root}/public/m_404.html", :layout => 'mobile', :status => 404
  end

  def share
    render :layout => false
  end

  def set_back
    @back = request.env['HTTP_REFERER']
    true
  end

  def cpyn
    render layout: 'cpyn'
  end

  def about_cpyn
    render layout: 'cpyn'
  end

  def cpyn_privacy
    render layout: 'cpyn'
  end

  def how_to_cpyn
    render layout: 'cpyn'
  end

  def cpyn_support
    render layout: 'cpyn'
  end

  def m_resume
    redirect_to resume_path, status: :moved_permanently
  end

  def summary
    render layout: false
  end

  def employment
    render layout: false
  end

  def education
    render layout: false
  end

  def apps
    render layout: false
  end
end
