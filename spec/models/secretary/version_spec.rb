require 'spec_helper'

describe Secretary::Version do
  describe "::generate" do
    it "generates a new version for passed-in object" do
      story   = create :story
      version = Secretary::Version.generate(story)

      Secretary::Version.count.should eq 2
      story.versions.last.should eq version
    end

    it "sets the user association" do
      user = create :user
      story   = create :story, logged_user_id: user.id
      version = Secretary::Version.generate(story)

      story.versions.last.user.should eq user
    end
  end


  describe "generating description" do
    let(:story) {
      build :story, :headline => "Cool story, bro", :body => "Cool text, bro."
    }

    it "generates a description with object name on create" do
      story.save!
      story.versions.last.description.should eq "Created Story ##{story.id}"
    end

    it "generates a description with the changed attributes on update" do
      story.save!
      image = create :image

      image.update_attributes({
        :story_id   => story.id,
        :url        => "http://kitty.com/kitty.jpg"
      })

      image.versions.last.description.should eq("Changed Story and Url")
    end
  end


  describe "incrementing version number" do
    it "sets version_number to 1 if no other versions exist for this object" do
      story = create :story
      story.versions.last.version_number.should eq 1
    end

    it "increments version number if versions already exist" do
      story = create :story, :headline => "Some Headline"
      story.versions.last.version_number.should eq 1
      story.update_attributes(:headline => "Cooler story, bro.")
      story.versions.last.version_number.should eq 2
      story.update_attributes(:headline => "Coolest story, bro!")
      story.versions.last.version_number.should eq 3
    end
  end


  describe '#attribute_diffs' do
    it 'is a hash of attribute keys, and Diffy::Diff objects' do
      story = create :story, :headline => "Cool story, bro"
      story.update_attributes!(:headline => "Updated Headline")

      version = story.versions.last
      version.attribute_diffs.keys.should eq ["headline"]
      version.attribute_diffs["headline"].should be_a Diffy::Diff
    end
  end


  describe '#title' do
    it "is the simple title for the version" do
      story = create :story
      story.versions.last.title.should eq "Story ##{story.id} v1"
    end
  end
end
