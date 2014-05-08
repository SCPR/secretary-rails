require 'spec_helper'
require 'generator_spec/test_case'
require 'generators/secretary/install_generator'

describe Secretary::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../../tmp", __FILE__)

  before do
    prepare_destination
    run_generator
  end

  it 'copies the migration file' do
    assert_migration "db/migrate/secretary_create_versions.rb"
  end

  it 'copies the config' do
    assert_file "config/initializers/secretary.rb"
  end
end
