require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_REFERER'] = '/'
  end

  should "get index" do
    get :index
    assert_response :success
  end

  should "get show view" do
    get :show, 'term' => 'slang'
    assert_response :success
    assert_not_nil assigns(:words)
  end

  teardown do
    assert_not_nil assigns(:theme)
  end

end
