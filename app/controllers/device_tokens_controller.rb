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

class DeviceTokensController < ApplicationController
  before_filter :verify_client_secret, except: :count
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def count
    prod_count = DeviceToken.where(production: true).count
    dev_count = DeviceToken.where(production: false).count
    respond_to do |format|
      format.json do
        respond_with({ prod: prod_count, dev: dev_count })
      end
    end
  end

  def create
    @device_token = DeviceToken.find_by_token_and_production params[:device_token][:token],
      params[:device_token][:production]

    if @device_token
      @device_token.update_attribute :updated_at, DateTime.now
      head :created, :location => @device_token
      return
    end

    @device_token = DeviceToken.create token_params
    head :invalid_entity and return unless @device_token.valid?

    head :created, :location => @device_token
  end

  def show
    head :bad_request
  end

  def destroy
    @device_token = DeviceToken.find_by_token params[:device_token][:token]
    @device_token.destroy

    head :ok
  end

  private

  def verify_client_secret
    client_version = params[:version]
    client_secret = params[:secret]
    expected_secret = client_secrets[client_version]

=begin
    puts "client_secrets: #{client_secrets}"
    puts "client_version: #{client_version.inspect}; client_secret: #{client_secret.inspect}"
    puts "params: #{params.inspect}; expected_secret: #{expected_secret.inspect}"
=end

    head :forbidden and return if client_version.nil? || client_secret.nil? || client_secret != expected_secret
  end

  def client_secrets
    file = File.join(Rails.root, 'config', "#{Rails.env}_client_secrets.yml")
    if @client_secrets.nil?
      # puts "loading #{file}"
      @client_secrets = YAML::load_file file
    end

    @client_secrets
  end

  def token_params
    params.require(:device_token).permit(:token,:production)
  end
end
