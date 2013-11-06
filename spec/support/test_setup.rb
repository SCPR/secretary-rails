require 'fileutils'

module TestSetup
  extend self

  DATABASE_CONFIG_FILE =
    File.expand_path("../../internal/config/database.yml", __FILE__)

  CONFIGS_ROOT =
    File.expand_path("../../internal/config/database_configs", __FILE__)

  def database
    ENV['DB'] ||= 'sqlite'
  end

  def setup
    move_database_config(database)
    initialize_app
  end

  def initialize_app
    require 'combustion'
    Combustion.initialize! :active_record, :action_view
  end

  def move_database_config(config)
    FileUtils.cp File.join(CONFIGS_ROOT, "#{config}.yml"), DATABASE_CONFIG_FILE
  end

  def remove_database_config
    FileUtils.rm(DATABASE_CONFIG_FILE)
  end

  def load_database_config
    ActiveRecord::Base.configurations =
      YAML.load(ERB.new(File.read(DATABASE_CONFIG_FILE)).result)
  end
end
