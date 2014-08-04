require 'spec_helper'

describe DeviceTokensController do
  before :each do
    DeviceToken.destroy_all
  end

  it 'responds to /devices_tokens/count' do
    request.env['HTTP_ACCEPT'] = 'application/json'
    get :count
    response.should be_success
  end

  it 'succeeds with a valid request' do
    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2',
      secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.should be_success

    token = assigns(:device_token)
    token.token.should == 'some-token'
    token.production.should be false
  end

  # The semantics here of POST/DELETE are add/remove this token to/from the active list.
  # If that token is already active, we respond the same as if the record were newly
  # created.
  it 'reports success on create if token already present' do
    DeviceToken.count.should == 0
    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2',
      secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.code.should == "201"
    DeviceToken.count.should == 1

    orig_time = DeviceToken.first.updated_at

    sleep 1

    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2',
      secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.code.should == "201"
    DeviceToken.count.should == 1

    DeviceToken.first.updated_at.should > orig_time
  end

  it 'fails with an invalid client secret in prod' do
    post :create, device_token: {token:'some-token', production: true}, version:'1.2.2',
      secret:'wrong-secret'
    response.code.should == "403"
  end

  it 'fails with an invalid client secret in dev' do
    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2',
      secret:'wrong-secret'
    response.code.should == "403"
  end

  it 'fails with a blank client secret in prod' do
    post :create, device_token: {token:'some-token', production: true}, version:'1.2.2'
    response.code.should == "403"
  end

  it 'succeeds with a blank client secret in dev' do
    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2'
    response.code.should == "201"
  end

  it 'deletes by token' do
    skip "not really necessary"
    DeviceToken.count.should == 0
    post :create, device_token: {token:'some-token', production: false}, version:'1.2.2',
      secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.code.should == "201"
    DeviceToken.count.should == 1

    # This is an HTTP DELETE /device_tokens with a payload like
    # {"device_token":{"token":"some-token"}, "version":"1.2.2", "secret":"..."},
    # rather than DELETE /device_tokens/:id.
    # To avoid having to store the ID for each token in order to deactivate it later,
    # we support delete by token instead of by ID. Hence this weird routing.
    delete :destroy, device_token: {token:'some-token'}, version:'1.2.2', secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.code.should == "200"

    DeviceToken.count.should == 0
  end

  # The show route is only provided so that we can have a device_token_path(@device_token)
  it 'does not respond to the show route' do
    get :show, id: 1, version:'1.2.2', secret:'BBE2C00F-15EF-4A5F-A773-F48E859226D8'
    response.code.should == "400"
  end
end
