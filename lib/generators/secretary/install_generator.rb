require 'rails/generators/active_record/migration'

module Secretary
  class InstallGenerator < Rails::Generators::Base
    if ActiveRecord::VERSION::MAJOR < 4
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration
    else
      include ActiveRecord::Generators::Migration
    end

    source_root File.expand_path("../templates", __FILE__)

    def copy_migration
      migration_template "versions_migration.rb", "db/migrate/create_versions"
    end
  end
end
