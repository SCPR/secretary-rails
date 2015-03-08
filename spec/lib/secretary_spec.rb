require 'spec_helper'

describe Secretary do
  describe "::configure" do
    it "accepts a block with the config object" do
      Secretary.configure do |config|
        expect(config).to be_a Secretary::Config
      end
    end

    it "sets Secretary.config to the new Config object" do
      config = Secretary.configure
      expect(Secretary.config).to eq config
    end
  end


  describe '::config' do
    it 'creates a new configuration if none is set' do
      expect(Secretary.config).to be_a Secretary::Config
    end

    it 'uses the set configuration if available' do
      id = Secretary.configure.object_id
      expect(Secretary.config.object_id).to eq id
    end
  end


  describe '::versioned_models' do
    it 'lists the name of all the versioned models' do
      Story # load the class
      expect(Secretary.versioned_models).to include "Story"

      class Something < ActiveRecord::Base
        self.table_name = "stories"
        has_secretary
      end

      expect(Secretary.versioned_models).to include "Story"
      expect(Secretary.versioned_models).to include "Something"
    end
  end
end
