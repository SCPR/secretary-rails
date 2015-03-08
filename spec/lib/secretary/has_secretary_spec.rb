require 'spec_helper'

describe Secretary::HasSecretary do
  let(:user) { create :user }

  let(:new_story) {
    build :story,
      :headline         => "Cool Story, Bro",
      :body             => "Some cool text.",
      :logged_user_id   => user.id
  }

  let(:other_story) {
    create :story,
      :headline         => "Cooler Story, Bro",
      :body             => "Some cooler text.",
      :logged_user_id   => user.id
  }


  describe "::has_secretary?" do
    it "returns false if no has_secretary declared" do
      expect(User.has_secretary?).to eq false
    end

    it "returns true if @_has_secretary is true" do
      expect(Story.has_secretary?).to eq true
    end
  end


  describe "::has_secretary" do
    it "sets @_has_secretary to true" do
      expect(Story.has_secretary?).to eq true
    end

    it 'adds the model to Secretary.versioned_models' do
      Story # Load the class
      expect(Secretary.versioned_models).to include "Story"
    end

    it 'sets versioned attributes if option is specified' do
      expect(Animal.versioned_attributes).to eq ["name", "color"]
    end

    it 'sets excluded attributes if option is specified' do
      expect(Person.versioned_attributes).not_to include "name"
      expect(Person.versioned_attributes).not_to include "ethnicity"
    end

    it "adds the has_many association for versions" do
      expect(new_story.versions.to_a).to eq Array.new
    end

    it "has logged_user_id" do
      expect(new_story).to respond_to :logged_user_id
      expect(new_story).to respond_to :logged_user_id=
    end

    it "generates a version on create" do
      expect(Secretary::Version.count).to eq 0
      new_story.save!
      expect(Secretary::Version.count).to eq 1
      expect(new_story.versions.count).to eq 1
    end

    it "generates a version when a record is changed" do
      other_story.update_attributes(:headline => "Some Cool Headline?!")
      expect(Secretary::Version.count).to eq 2
      expect(other_story.versions.size).to eq 2
    end

    it "doesn't generate a version if no attributes were changed" do
      other_story.save!
      expect(other_story.versions.size).to eq 1
      other_story.save!
      expect(other_story.versions.size).to eq 1
    end

    it "destroys all versions when the object is destroyed" do
      other_story.update_attributes!(:headline => "Changed the headline")
      expect(other_story.versions.size).to eq 2
      expect(Secretary::Version.count).to eq 2
      other_story.destroy
      expect(Secretary::Version.count).to eq 0
    end
  end
end
