# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101104214054) do

  create_table "inflections", :force => true do |t|
    t.string  "name",    :null => false
    t.integer "word_id"
  end

  add_index "inflections", ["name"], :name => "index_inflections_on_name"

  create_table "senses", :force => true do |t|
    t.integer "synset_id"
    t.integer "word_id"
    t.integer "freq_cnt",  :default => 0, :null => false
  end

  create_table "synsets", :force => true do |t|
    t.text    "definition",     :null => false
    t.integer "offset"
    t.string  "part_of_speech"
    t.string  "lexname",        :null => false
  end

  create_table "words", :force => true do |t|
    t.string  "name",                          :null => false
    t.string  "part_of_speech",                :null => false
    t.integer "freq_cnt",       :default => 0, :null => false
  end

  add_index "words", ["freq_cnt", "name"], :name => "index_words_on_freq_cnt_and_name"
  add_index "words", ["name", "part_of_speech"], :name => "index_words_on_name_and_part_of_speech"
  add_index "words", ["name"], :name => "index_words_on_name"

end
