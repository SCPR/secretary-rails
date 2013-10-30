require 'spec_helper'

describe Secretary::Config do
  describe "::configure" do
    it "generates a new Config object" do
      Secretary::Config.should_receive(:new)
      Secretary::Config.configure
    end

    it "accepts a block with the config object" do
      Secretary::Config.configure do |config|
        config.should be_a Secretary::Config
      end
    end

    it "sets Secretary.config to the new Config object" do
      Secretary::Config.should_receive(:new).and_return("Config")
      Secretary::Config.configure
      Secretary.config.should eq "Config"
    end
  end


  describe "#user_class" do
    it "uses the default if not set" do
      stub_const("Secretary::Config::DEFAULTS", { user_class: "Person"} )
      config = Secretary::Config.new
      config.instance_variable_get(:@user_class).should be_nil
      config.user_class.should eq "Person"
    end
  end
end
