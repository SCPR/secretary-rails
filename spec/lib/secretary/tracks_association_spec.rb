require 'spec_helper'

describe Secretary::TracksAssociation do
  describe '::tracks_association' do
    it "raises an error if the model isn't versioned" do
      expect {
        User.tracks_association
      }.to raise_error Secretary::NotVersionedError
    end

    it "raises an error if there is no association with the given name" do
      expect {
        Person.tracks_association :giraffes
      }.to raise_error Secretary::NoAssociationError
    end

    it 'adds the associations to the versioned attributes' do
      expect(Person.versioned_attributes).to include "animals"
      expect(Person.versioned_attributes).to include "hobbies"
    end
  end
end
