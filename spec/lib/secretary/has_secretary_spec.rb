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

    it "adds the has_many association for versions" do
      new_story.should have_many(:versions)
        .dependent(:destroy).class_name("Secretary::Version")
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


  describe '#changes' do
    it 'is the built-in changes reverse-merged with custom changes' do
      story = create :story, headline: "Original Headline"
      story.headline = "Updated Headline!"
      story.custom_changes['assets'] = [[], { a: 1, b: 2 }]

      story.changes.should eq Hash[{
        'headline' => ['Original Headline', "Updated Headline!"],
        'assets'   => [[], { 'a' => 1, 'b' => 2 }]
      }]
    end
  end


  describe '#changed?' do
    it 'checks if custom changes are present as well' do
      other_story.changed?.should eq false
      other_story.custom_changes['assets'] = [[], { a: 1, b: 2 }]
      other_story.changed?.should eq true
    end
  end


  describe '#custom_changes' do
    it 'is a hash into which you can put things' do
      other_story.custom_changes['something'] = ['old', 'new']
    end

    it 'gets cleared after saved' do
      other_story.custom_changes["something"] = ["old", "new"]
      other_story.custom_changes.should eq Hash[{"something" => ["old", "new"]}]
      other_story.save!
      other_story.custom_changes.should eq Hash[]
    end
  end
end
