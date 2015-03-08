require 'spec_helper'

describe Secretary::VersionedAttributes do
  describe '::versioned_attributes' do
    it 'uses the attributes set in the model' do
      expect(Animal.versioned_attributes).to eq ["name", "color"]
    end

    it 'uses the column names minus the global ignores if nothing is set' do
      expect(Location.versioned_attributes).to eq ["title", "address", "people"]
    end

    it 'subtracts unversioned attributes if they are set' do
      expect(Person.versioned_attributes).not_to include "name"
      expect(Person.versioned_attributes).not_to include "ethnicity"
    end
  end

  describe '::versioned_attributes=' do
    it 'sets the versioned attributes' do
      original = Person.versioned_attributes

      Person.versioned_attributes = ["name"]
      expect(Person.versioned_attributes).to eq ["name"]

      Person.versioned_attributes = original
    end

    it "raises ArgumentError if any of the attributes aren't strings" do
      expect {
        Person.versioned_attributes = [:a, :b, "c"]
      }.to raise_error ArgumentError
    end
  end


  describe '::unversioned_attributes=' do
    it "removes the attributes from the versioned attributes" do
      original = Person.versioned_attributes

      Person.versioned_attributes = ["name", "ethnicity"]
      Person.unversioned_attributes = ["name"]
      expect(Person.versioned_attributes).to eq ["ethnicity"]

      Person.versioned_attributes = original
    end

    it "raises ArgumentError if any of the attributes aren't strings" do
      expect {
        Person.unversioned_attributes = [:a, :b, "c"]
      }.to raise_error ArgumentError
    end
  end


  describe '#versioned_changes' do
    let(:person) { create :person }

    it 'is empty for non-dirty objects' do
      expect(person.versioned_changes).to eq Hash[]
    end

    it "return a hash of changes for just the attributes we want" do
      person.age  = 120
      person.name = "Freddie"

      expect(person.versioned_changes).to eq Hash[{
        "age" => [100, 120]
      }]
    end
  end


  describe '#versioned_attributes' do
    let(:animal) { create :animal, :name => "Henry", :color => "henry" }

    it 'is only the attributes we want' do
      expect(animal.versioned_attributes).to eq Hash[{
        "name" => "Henry",
        "color" => "henry"
      }]
    end
  end


  describe '#versioned_attribute?' do
    let(:person) { create :person }

    it 'is true if the attribute should be versioned' do
      expect(person.versioned_attribute?("age")).to eq true
      expect(person.versioned_attribute?(:age)).to eq true
    end

    it 'is false if the attribute should not be versioned' do
      expect(person.versioned_attribute?("name")).to eq false
      expect(person.versioned_attribute?("id")).to eq false
    end
  end
end
