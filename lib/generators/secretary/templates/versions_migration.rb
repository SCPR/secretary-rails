class SecretaryCreateVersions < ActiveRecord::Migration
  def change
    create_table "versions" do |t|
      t.integer  "version_number"
      t.string   "versioned_type"
      t.integer  "versioned_id"
      t.string   "user_id"
      t.text     "description"
      t.text     "object_changes"
      t.datetime "created_at"
    end

    add_index "versions", ["created_at"]
    add_index "versions", ["user_id"]
    add_index "versions", ["version_number"]
    add_index "versions", ["versioned_type", "versioned_id"]
  end
end
