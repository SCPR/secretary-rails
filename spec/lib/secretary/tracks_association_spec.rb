require 'spec_helper'

describe Secretary::TracksAssociation do
  describe '::tracks_association' do
    it "raises an error if the model isn't versioned" do
      -> {
        User.tracks_association
      }.should raise_error Secretary::NotVersionedError
    end

    it 'adds the associations to the versioned attributes' do
      Person.versioned_attributes.should include "animals"
      Person.versioned_attributes.should include "hobbies"
    end
  end


  describe 'dirty association' do
    let(:person) { create :person }
    let(:animal) { create :animal }

    it 'sets associations_were' do
      person.animals << animal
      person.animals_were.should eq []
    end

    it 'marks the association as changed when the association is changed' do
      person.animals << animal
      person.animals_changed?.should eq true
    end

    it 'clears out the dirty association after commit' do
      person.animals << animal
      person.animals_changed?.should eq true
      person.save!
      person.animals_changed?.should eq false
    end
  end


  describe "adding to association collections" do
    let(:person) { create :person }
    let(:animal) { build :animal, name: "Bob", color: "dog" }

    it "creates a new version when adding" do
      person.animals = [animal]
      person.save!

      person.versions.count.should eq 2
      version = person.versions.last
      version.object_changes["animals"][0].should eq []

      version.object_changes["animals"][1].should eq [
        {"name" => "Bob", "color" => "dog"}
      ]
    end

    it 'makes a version when adding' do
      person  = create :person
      animal  = build :animal, name: "Bryan", color: 'lame'

      person.animals << animal
      person.save!
      person.versions.count.should eq 2

      versions = person.versions.order('version_number').to_a
      versions.last.object_changes["animals"][0].should eq []
      versions.last.object_changes["animals"][1].should eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
    end

    it 'makes a version when removing' do
      person  = build :person
      animal  = build :animal, name: "Bryan", color: 'lame'
      person.animals = [animal]
      person.save!
      person.versions.count.should eq 1

      person.animals = []
      person.save!
      person.versions.count.should eq 2

      versions = person.versions.order('version_number').to_a
      versions.last.object_changes["animals"][0].should eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
      versions.last.object_changes["animals"][1].should eq []
    end
  end


  describe 'with accepts_nested_attributes_for' do
    let(:animal) { create :animal, name: "Henry", color: "blind" }
    let(:person) { create :person }

    it 'adds a new version when adding to collection' do
      animals_attributes = [
        {
          "name" => "George",
          "color" => "yes"
        }
      ]

      person.animals_attributes = animals_attributes
      person.save!
      person.versions.count.should eq 2

      version = person.versions.order('version_number').last
      version.object_changes["animals"][0].should eq []
      version.object_changes["animals"][1].should eq [{
        "name" => "George",
        "color" => "yes"
      }]
    end

    it 'adds a new version when changing something in collection' do
      pending
      animals_attributes = [
        {
          "id" => animal.id,
          "name" => "Lemon"
        }
      ]

      person.animals << animal
      person.save!
      person.versions.count.should eq 2
      person.animals_attributes = animals_attributes # this doesn't call before_add/remove callbacks
      person.versions.count.should eq 3

      version = person.versions.order('version_number').last
      version.object_changes["animals"][0].should eq [{
        "name" => "Henry",
        "color" => "blind"
      }]
      version.object_changes["animals"][1].should eq [{
        "name" => "Lemon",
        "color" => "blind"
      }]
    end

    it 'does not add a new version if nothing has changed' do
    end
  end
end
