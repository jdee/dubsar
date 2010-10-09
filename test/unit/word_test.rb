require 'test_helper'

class WordTest < ActiveSupport::TestCase
  should validate_presence_of   :name
  should validate_presence_of :part_of_speech
  should have_many :definitions

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

  should 'not accept a word with an invalid part of speech' do
    w = words(:bad_part_of_speech)
    assert_equal w.valid?, false
  end

  should 'recognize words with different parts of speech as distinct' do
    well_adverb = words :adverb
    well_noun   = words :well_noun

    assert_valid well_adverb
    assert_valid well_noun

    assert_equal well_adverb.name, well_noun.name
    assert_not_equal well_adverb.part_of_speech, well_noun.part_of_speech
  end

  should 'recognize synonyms' do
    food = words :noun
    grub = words :grub

    assert food.include_synonym?(grub.name)
    assert grub.include_synonym?(food.name)
  end

end
