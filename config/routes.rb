#  Dubsar Dictionary Project
#  Copyright (C) 2010-15 Jimmy Dee
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

Dubsar::Application.routes.draw do
  get '/downloads', to: 'downloads#index'

  devise_for :users

  resources :tokens, :only => [:create, :destroy]

  resources :device_tokens, :only => [:create, :show ] do
    get '/count', to: 'device_tokens#count', on: :collection
  end

  # delete :device_tokens, to: 'device_tokens#destroy'

  resources :words  , :only => :show
  resources :senses , :only => :show
  resources :synsets, :only => :show

  get '/about'            , to: 'words#about'
  get '/faq'              , to: 'words#faq'
  get '/m_faq'            , to: 'words#m_faq'
  get '/ios_faq'          , to: 'words#ios_faq'
  get '/ios_faq_v120'     , to: 'words#ios_faq_v120'
  get '/ios_faq_v200'     , to: 'words#ios_faq_v200'
  get '/license'          , to: 'words#license'
  get '/m_support'        , to: 'words#m_support'
  get '/m_senses/:id'     , to: 'senses#m_show'
  get '/m_words/:id'      , to: 'words#m_show'
  get '/m_synsets/:id'    , to: 'synsets#m_show'
  # get '/link'             , to: 'words#link'
  # get '/qunit'            , to: 'words#qunit'
  # get '/review'           , to: 'inflections#review'
  # get '/share'            , to: 'application#share'
  # get '/tour'             , to: 'words#tour'
  get '/wotd'             , to: 'words#wotd'
  get '/privacy'          , to: 'words#privacy'
  get '/m_privacy'        , to: 'words#m_privacy'
  get '/news'             , to: 'words#news'
  get '/ios_news_v200'    , to: 'words#ios_news_v200'

  get '/resume'           , to: 'application#resume'
  get '/m_resume'         , to: 'application#m_resume'

  get '/m_laertes_faq'    , to: 'words#m_laertes_faq'

  get '/(.:format)', to: 'words#search'
  get '/os(.:format)', to: 'words#os'

  get '/pingpong', to: 'application#pingpong'

  root :to => "application#index"

  # Currently suppresses things like /rails/info/routes. Need to except that.
  get '/*junk', to: "application#error"
end
