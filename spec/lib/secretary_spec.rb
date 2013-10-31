require 'spec_helper'

describe Secretary do
  describe "::configure" do
    it "accepts a block with the config object" do
      Secretary.configure do |config|
        config.should be_a Secretary::Config
      end
    end

    it "sets Secretary.config to the new Config object" do
      config = Secretary.configure
      Secretary.config.should eq config
    end
  end


  describe '::config' do
    it 'creates a new configuration if none is set' do
      Secretary.config.should be_a Secretary::Config
    end

    it 'uses the set configuration if available' do
      id = Secretary.configure.object_id
      Secretary.config.object_id.should eq id
    end
  end


  describe '::versioned_models' do
    it 'lists the name of all the versioned models' do
      Story # load the class
      Secretary.versioned_models.should include "Story"

      class Something < ActiveRecord::Base
        self.table_name = "stories"
        has_secretary
      end

      Secretary.versioned_models.should include "Story"
      Secretary.versioned_models.should include "Something"
    end
  end
end
