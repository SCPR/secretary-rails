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
    let(:animal) { create :animal }

    it "creates a new version when adding", focus: true do
      person.animals << animal
      person.save!

      person.versions.count.should eq 2
      version = person.versions.last
      version.object_changes["animals"][0].should eq []
      version.object_changes["animals"][1].should eq []
    end

    it "creates a new version when removing" do
    end
  end
end
