class DownloadsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        file = File.expand_path('config/downloads.yml', Rails.root)
        downloads = YAML::load_file file

        p downloads

        downloads.each do |download|
          download.symbolize_keys!

          dlfile = File.join(Rails.root, 'public', "#{download[:name]}.zip")

          download[:zipped] = File.size(dlfile)
          download[:mtime] = File.mtime(dlfile)
        end

        respond_with downloads.to_json
      end
    end
  end
end
