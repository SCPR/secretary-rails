ActiveRecord::Schema.define do
  create_table "stories", force: true do |t|
    t.string  "headline"
    t.text    "body"
    t.timestamps
  end

  create_table "users", force: true do |t|
    t.string "name"
    t.timestamps
  end

  create_table "versions", force: true do |t|
    t.integer   "version_number"
    t.string    "versioned_type"
    t.integer   "versioned_id"
    t.integer   "user_id"
    t.text      "description"
    t.text      "object_changes"
    t.datetime  "created_at"
  end
end
