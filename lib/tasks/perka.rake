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

require 'net/http'
require 'yaml'

namespace :perka do
  desc 'Apply to Perka'
  task :apply do
    # 1. Open the resume file. Buffer all data. Base64-encode.
    file_name = ENV['RESUME'] || 'JimmyDee.pdf'
    resume_path = File.join Rails.root, file_name

    # IO.read and YAML::load_file raise exceptions if the files are not present
    resume_data = Base64.encode64 IO.read(resume_path)

    # 2. Load payload from YAML file
    payload = YAML::load_file(File.join Rails.root, 'config', 'perka.yml').symbolize_keys
    payload.merge! resume: resume_data

    # 3. POST to the endpoint
    uri = URI('https://getperka.com/api/2/apply')

    # Prepare the JSON POST request
    req = Net::HTTP::Post.new uri
    req['Accept'] = 'application/json'
    req['Content-type'] = 'application/json'
    req.body = payload.to_json

    puts "#{DateTime.now} attempting POST to #{uri}"

    resp = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request req
    end

    puts "#{DateTime.now} #{resp.code} #{resp.message}"

  end
end
