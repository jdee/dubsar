require 'test_helper'

class WordTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :part_of_speech

  should 'accept a valid adjective' do
    assert_valid words(:noun)
  end

  should 'accept a valid adverb' do
    assert_valid words(:adverb)
  end

  should 'accept a valid conjunction' do
    assert_valid words(:conjunction)
  end

  should 'accept a valid interjection' do
    assert_valid words(:interjection)
  end

  should 'accept a valid noun' do
    assert_valid words(:noun)
  end

  should 'accept a valid preposition' do
    assert_valid words(:preposition)
  end

  should 'accept a valid pronoun' do
    assert_valid words(:pronoun)
  end

  should 'accept a valid verb' do
    assert_valid words(:verb)
  end

end
