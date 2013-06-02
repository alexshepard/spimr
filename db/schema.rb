# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130602022028) do

  create_table "sightings", :force => true do |t|
    t.integer  "spime_id"
    t.string   "location_name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "finder_person_name"
    t.datetime "date"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "spimes", :force => true do |t|
    t.string   "name",              :null => false
    t.text     "description",       :null => false
    t.string   "image",             :null => false
    t.boolean  "public",            :null => false
    t.text     "materials",         :null => false
    t.datetime "date_manufactured", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "uuid"
  end

end
