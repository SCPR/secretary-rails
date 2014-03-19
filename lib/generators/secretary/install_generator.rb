require 'rails/generators/base'

module Secretary
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    if ActiveRecord::VERSION::MAJOR < 4
      require 'rails/generators/active_record/migration'
      extend ActiveRecord::Generators::Migration
    else
      require 'rails/generators/active_record'
      def self.next_migration_number(*args)
        ActiveRecord::Generators::Base.next_migration_number(*args)
      end
    end

    source_root File.expand_path("../templates", __FILE__)

    def copy_migration
      migration_template "versions_migration.rb", "db/migrate/secretary_create_versions"
    end
  end
end
