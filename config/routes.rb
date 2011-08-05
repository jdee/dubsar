#  Dubsar Dictionary Project
#  Copyright (C) 2010-11 Jimmy Dee
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
  resources :fairies, :only => [ :index, :create ]

  resources :words  , :only => :show do
    match '/tab' => 'words#tab'
  end
  resources :senses , :only => :show do
    match '/tab' => 'senses#tab'
  end
  resources :synsets, :only => :show do
    match '/tab' => 'synsets#tab'
  end

  match '/about'             => 'words#about'
  match '/faq'               => 'words#faq'
  match '/license'           => 'words#license'
  match '/m'                 => 'words#mobile'
  match '/m_faq'             => 'words#m_faq'
  match '/m_license'         => 'words#m_license'
  match '/m_support'         => 'words#m_support'
  match '/m_search'          => 'words#m_search'
  match '/m_senses/:id'      => 'senses#m_show'
  match '/m_words/:id'       => 'words#m_show'
  match '/m_synsets/:id'     => 'synsets#m_show'
  match '/link'              => 'words#link'
  match '/qunit'             => 'words#qunit'
  match '/share'             => 'application#share'
  match '/tour'              => 'words#tour'
  match '/wotd'              => 'words#wotd'

  match '/(.:format)' => 'words#search'
  match '/os(.:format)' => 'words#os'

  root :to => "words#index"

  match '*junk' => "application#error"
end
