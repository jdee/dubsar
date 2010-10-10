require 'test_helper'

class WordsControllerTest < ActionController::TestCase
  should "get index" do
    get :index
    assert_response :success
  end

  should "get show view" do
    get :show, 'name' => 'slang'
    assert_response :success
    assert_not_nil assigns(:words)
  end

end
