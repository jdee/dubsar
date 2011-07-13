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

describe SensesController do
  context "handling basic routing and requests" do
    before :each do
      request.env['HTTP_REFERER'] = '/'
    end

    it "gets the :show view" do
      food, grub = create_synonyms!
      sense = food.senses.first
      get :show, 'id' => sense.id
      response.should be_success
      assigns(:sense).should_not be_blank
    end

    it "gives an error when ID not found" do
      %w{show m_show}.each do |route|
        get route, 'id' => 1_000_000
        response.status.should == 404
      end
    end

    it "gets the :m_show view" do
      food, grub = create_synonyms!
      sense = food.senses.first
      get :m_show, 'id' => sense.id
      response.should be_success
      assigns(:sense).should_not be_blank
    end
  end
end
