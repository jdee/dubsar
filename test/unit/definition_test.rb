require 'test_helper'

class DefinitionTest < ActiveSupport::TestCase
  should validate_presence_of :body

  should 'accept a valid definition' do
    assert_valid definitions(:slang)
  end
end
