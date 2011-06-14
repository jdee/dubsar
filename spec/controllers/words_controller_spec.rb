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

require 'spec_helper'

describe WordsController do
  before :each do
    request.env['HTTP_REFERER'] = '/'
  end

  it "gets :index" do
    get :index
    response.should be_success
  end

  it "gets :show view" do
    Factory.create :slang
    get :show, 'term' => 'slang'
    response.should be_success
    assigns(:words).should_not be_nil
  end

  it "ignores excess white space" do
    get :show, 'term' => '  World   War         2  '

    assigns(:term).should_not be_nil
    assigns(:term).should == 'World War 2'
  end

  after :each do
    assigns(:theme).should_not be_nil
  end
end
