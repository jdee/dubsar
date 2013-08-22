require 'spec_helper'

describe DeviceToken do
  let(:no_token) { DeviceToken.new production: false }
  # let(:no_production) { DeviceToken.new token: 'abc' }
  let(:valid) { DeviceToken.new token: 'abc', production: false }

  it 'should not be valid without a token' do
    no_token.should_not be_valid
  end

  it 'should be valid with token and production flag' do
    valid.should be_valid
  end
end
