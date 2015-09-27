class AddClientVersionToDeviceTokens < ActiveRecord::Migration
  def change
    add_column :device_tokens, :client_version, :string
  end
end
