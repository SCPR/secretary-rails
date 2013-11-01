require 'spec_helper'

describe Secretary::VersionedAttributes do
  describe '::versioned_attributes' do
    it 'uses the attributes set in the model' do
      Animal.versioned_attributes.should eq ["name", "color"]
    end

    it 'uses the column names minus the global ignores if nothing is set' do
      Location.versioned_attributes.should eq ["title", "address", "people"]
    end

    it 'subtracts unversioned attributes if they are set' do
      Person.versioned_attributes.should_not include "name"
      Person.versioned_attributes.should_not include "ethnicity"
    end
  end


  describe '#versioned_changes' do
    let(:person) { create :person }

    it 'is empty for non-dirty objects' do
      person.versioned_changes.should eq Hash[]
    end

    it "return a hash of changes for just the attributes we want" do
      person.age  = 120
      person.name = "Freddie"

      person.versioned_changes.should eq Hash[{
        "age" => [100, 120]
      }]
    end
  end


  describe '#versioned_attributes' do
    let(:animal) { create :animal, name: "Henry", color: "henry" }

    it 'is only the attributes we want' do
      animal.versioned_attributes.should eq Hash[{
        "name" => "Henry",
        "color" => "henry"
      }]
    end
  end


  describe '#versioned_attribute?' do
    let(:person) { create :person }

    it 'is true if the attribute should be versioned' do
      person.versioned_attribute?("age").should eq true
      person.versioned_attribute?(:age).should eq true
    end

    it 'is false if the attribute should not be versioned' do
      person.versioned_attribute?("name").should eq false
      person.versioned_attribute?("id").should eq false
    end
  end
end
