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

source 'http://rubygems.org'

gem 'builder'
gem 'haml'
gem 'sqlite3', '~> 1.3.6'
gem 'rails', '>= 4.0'
gem 'will_paginate', '~> 3.0'
gem 'devise'
gem 'uglifier'

group :production do
  gem 'therubyracer'
end

group :backup_dev, :development, :test do
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'capistrano'
  gem 'factory_girl_rails'
  gem 'json'
  gem 'simplecov', require: false
  gem 'rspec-rails', '~> 2.99'
  gem 'rvm-capistrano', require: false
  gem 'webrat'
  gem 'nokogiri'
end
