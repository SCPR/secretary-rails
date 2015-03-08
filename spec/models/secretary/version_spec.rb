require 'spec_helper'

describe Secretary::Version do
  describe "::generate" do
    it "generates a new version for passed-in object" do
      story   = create :story
      version = Secretary::Version.generate(story)

      expect(Secretary::Version.count).to eq 2
      expect(story.versions.last).to eq version
    end

    it "sets the user association" do
      user = create :user
      story   = create :story, logged_user_id: user.id
      version = Secretary::Version.generate(story)

      expect(story.versions.last.user).to eq user
    end
  end


  describe "generating description" do
    let(:story) {
      build :story, :headline => "Cool story, bro", :body => "Cool text, bro."
    }

    it "generates a description with object name on create" do
      story.save!
      expect(story.versions.last.description).to eq "Created Story ##{story.id}"
    end

    it "generates a description with the changed attributes on update" do
      story.save!
      image = create :image

      image.update_attributes({
        :story_id   => story.id,
        :url        => "http://kitty.com/kitty.jpg"
      })

      expect(image.versions.last.description).to eq("Changed Story and Url")
    end
  end


  describe "incrementing version number" do
    it "sets version_number to 1 if no other versions exist for this object" do
      story = create :story
      expect(story.versions.last.version_number).to eq 1
    end

    it "increments version number if versions already exist" do
      story = create :story, :headline => "Some Headline"
      expect(story.versions.last.version_number).to eq 1
      story.update_attributes(:headline => "Cooler story, bro.")
      expect(story.versions.last.version_number).to eq 2
      story.update_attributes(:headline => "Coolest story, bro!")
      expect(story.versions.last.version_number).to eq 3
    end
  end


  describe '#attribute_diffs' do
    it 'is a hash of attribute keys, and Diffy::Diff objects' do
      story = create :story, :headline => "Cool story, bro"
      story.update_attributes!(:headline => "Updated Headline")

      version = story.versions.last
      expect(version.attribute_diffs.keys).to eq ["headline"]
      expect(version.attribute_diffs["headline"]).to be_a Diffy::Diff
    end
  end


  describe '#title' do
    it "is the simple title for the version" do
      story = create :story
      expect(story.versions.last.title).to eq "Story ##{story.id} v1"
    end
  end
end
