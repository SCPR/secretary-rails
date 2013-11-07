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
      User.has_secretary?.should eq false
    end

    it "returns true if @_has_secretary is true" do
      Story.has_secretary?.should eq true
    end
  end


  describe "::has_secretary" do
    it "sets @_has_secretary to true" do
      Story.has_secretary?.should eq true
    end

    it 'adds the model to Secretary.versioned_models' do
      Story # Load the class
      Secretary.versioned_models.should include "Story"
    end

    it 'sets versioned attributes if option is specified' do
      Animal.versioned_attributes.should eq ["name", "color"]
    end

    it 'sets excluded attributes if option is specified' do
      Person.versioned_attributes.should_not include "name"
      Person.versioned_attributes.should_not include "ethnicity"
    end

    it "adds the has_many association for versions" do
      new_story.versions.to_a.should eq Array.new
    end

    it "has logged_user_id" do
      new_story.should respond_to :logged_user_id
      new_story.should respond_to :logged_user_id=
    end

    it "generates a version on create" do
      Secretary::Version.count.should eq 0
      new_story.save!
      Secretary::Version.count.should eq 1
      new_story.versions.count.should eq 1
    end

    it "generates a version when a record is changed" do
      other_story.update_attributes(headline: "Some Cool Headline?!")
      Secretary::Version.count.should eq 2
      other_story.versions.size.should eq 2
    end

    it "doesn't generate a version if no attributes were changed" do
      other_story.save!
      other_story.versions.size.should eq 1
      other_story.save!
      other_story.versions.size.should eq 1
    end

    it "destroys all versions when the object is destroyed" do
      other_story.update_attributes!(headline: "Changed the headline")
      other_story.versions.size.should eq 2
      Secretary::Version.count.should eq 2
      other_story.destroy
      Secretary::Version.count.should eq 0
    end
  end
end
