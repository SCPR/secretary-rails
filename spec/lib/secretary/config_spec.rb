require 'spec_helper'

describe Secretary::Config do
  let(:config) { Secretary::Config.new }
  subject { config }

  describe '#user_class' do
    subject { super().user_class }
    it { is_expected.to eq "::User" }
  end

  describe '#ignored_attributes' do
    subject { super().ignored_attributes }
    it { is_expected.to eq ['id', 'created_at', 'updated_at'] }
  end
end
