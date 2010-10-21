require 'string'
require 'test_helper'

class StringTest < ActiveSupport::TestCase
  should 'respond_to new methods' do
    assert 'foo'.respond_to?(:upcase?)
    assert 'bar'.respond_to?(:capitalized?)
  end

  should 'detect all-uppercase words' do
    assert 'ABC'.upcase?
    assert(!'Abc'.upcase?)
  end

  should 'detect capitalized words' do
    assert 'ABC'.capitalized?
    assert 'Abc'.capitalized?
    assert(!'aBc'.capitalized?)
  end
end
