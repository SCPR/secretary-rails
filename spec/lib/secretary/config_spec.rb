require 'spec_helper'

describe Secretary::Config do
  let(:config) { Secretary::Config.new }
  subject { config }

  its(:user_class) { should eq "::User" }
  its(:ignored_attributes) { should eq ['id', 'created_at', 'updated_at'] }
end
