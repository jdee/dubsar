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

describe FairiesController do
  it "gets :index" do
    get :index
    response.should be_success
  end

  context "when creating a new entry" do
    before :each do
      request.env['HTTP_REFERER'] = '/fairies'
    end

    it 'redirects to the index on success' do
      post :create, :fairy => { :name => 'Oberon', :email => 'oberon@fairies.org', :phone_number => '800-555-1212' }, :back => 'yes'
      response.should be_redirect
      response.should redirect_to(:action => :index)
      request.flash[:notice].should contain('Successfully saved. Thank you.')
    end

    it 'reports any errors' do
      post :create, :fairy => { :name => 'Puck' }, :back => 'yes'
      response.should be_redirect
      response.should redirect_to(:action => :index)
      request.flash[:error].should contain("Validation failed: Email can't be blank")
    end
  end
end
