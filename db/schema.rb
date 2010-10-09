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

ActiveRecord::Schema.define(:version => 20101009013851) do

  create_table "definitions", :force => true do |t|
    t.integer  "word_id"
    t.text     "body",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "words", :force => true do |t|
    t.string   "name",           :null => false
    t.string   "part_of_speech", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "words", ["name", "part_of_speech"], :name => "index_words_on_name_and_part_of_speech"
  add_index "words", ["name"], :name => "index_words_on_name"

end
