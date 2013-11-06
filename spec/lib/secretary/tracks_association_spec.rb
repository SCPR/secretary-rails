require 'spec_helper'

describe Secretary::TracksAssociation do
  describe '::tracks_association' do
    it "raises an error if the model isn't versioned" do
      -> {
        User.tracks_association
      }.should raise_error Secretary::NotVersionedError
    end

    it "raises an error if there is no association with the given name" do
      -> {
        Person.tracks_association :giraffes
      }.should raise_error Secretary::NoAssociationError
    end

    it 'adds the associations to the versioned attributes' do
      Person.versioned_attributes.should include "animals"
      Person.versioned_attributes.should include "hobbies"
    end
  end
end
