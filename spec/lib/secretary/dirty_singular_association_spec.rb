require 'spec_helper'

describe "Dirty Singular Association" do
  describe 'has_one' do
    let(:story) { create :story }
    let(:image) { create :image, :title => "Superman", :url => "superman.jpg" }

    it 'sets association_was' do
      story.image = image
      story.image_was.should eq nil
      story.save!
      story.image_was.should eq image
    end

    it 'marks the association as changed when the association is changed' do
      story.image = image
      story.image_changed?.should eq true
    end

    it 'clears out the dirty association after commit' do
      story.image = image
      story.image_changed?.should eq true
      story.save!
      story.image_changed?.should eq false
    end

    it "creates a new version when setting the association" do
      story.image = image
      story.save!

      story.versions.count.should eq 2
      version = story.versions.last
      version.object_changes["image"][0].should eq Hash[]

      version.object_changes["image"][1].should eq Hash[{
        "title" => "Superman",
        "url" => "superman.jpg"
      }]
    end

    it 'makes a version when removing' do
      story.image = image
      story.save!
      story.versions.count.should eq 2

      story.image = nil
      story.save!
      story.versions.count.should eq 3

      versions = story.versions.order('version_number').to_a
      versions.last.object_changes["image"][0].should eq Hash[{
        "title" => "Superman",
        "url" => "superman.jpg"
      }]
      versions.last.object_changes["image"][1].should eq Hash[]
    end


    context 'with accepts_nested_attributes_for' do
      it 'adds a new version when adding association' do
        image_attributes = {
          "title" => "Superman",
          "url" => "super.jpg"
        }

        story.image_attributes = image_attributes
        story.save!
        story.versions.count.should eq 2

        version = story.versions.order('version_number').last
        version.object_changes["image"][0].should eq Hash[]
        version.object_changes["image"][1].should eq Hash[{
          "title" => "Superman",
          "url" => "super.jpg"
        }]
      end

      it 'adds a new version when changing the existing associated object' do
        image_attributes = {
          "id" => image.id,
          "title" => "Lemon"
        }

        story.image = image
        story.save!
        story.versions.count.should eq 2

        story.image_attributes = image_attributes
        story.save!
        story.versions.count.should eq 3

        version = story.versions.order('version_number').last
        version.object_changes["image"][0].should eq Hash[{
          "title" => "Superman",
          "url" => "superman.jpg"
        }]
        version.object_changes["image"][1].should eq Hash[{
          "title" => "Lemon",
          "url" => "superman.jpg"
        }]
      end

      it 'adds a new version when removing the association' do
        image_attributes = {
          "id" => image.id,
          "_destroy" => "1"
        }

        story.image = image
        story.save!
        story.versions.count.should eq 2

        story.image_attributes = image_attributes
        story.save!
        story.versions.count.should eq 3

        version = story.versions.order('version_number').last
        version.object_changes["image"][0].should eq Hash[{
          "title" => "Superman",
          "url" => "superman.jpg"
        }]
        version.object_changes["image"][1].should eq Hash[]
      end

      it 'does not add a new version if nothing has changed' do
        pending "single associations save versions even if not changed"

        image_attributes = {
          "id" => image.id,
          "title" => "Superman"
        }

        story.image = image
        story.save!
        story.versions.count.should eq 2

        story.image_attributes = image_attributes
        story.save!
        story.versions.count.should eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        story.image_changed?.should eq false
        story.image = image
        story.image_changed?.should eq true
      end

      it 'is false after the parent object has been saved' do
        story.image = image
        story.image_changed?.should eq true
        story.save!
        story.image_changed?.should eq false
      end

      it 'is false if the association has not changed' do
        pending "single associations save versions even if not changed"

        story.image = image
        story.image_changed?.should eq true
        story.save!
        story.image_changed?.should eq false

        story.image = image
        story.image_changed?.should eq false
      end
    end
  end



  describe 'belongs_to' do
    let(:story) { create :story, :headline => "Headline", :body => "Body" }
    let(:image) { create :image, :title => "Superman", :url => "superman.jpg" }

    it 'sets association_was' do
      image.story = story
      image.story_was.should eq nil
      image.save!
      image.story_was.should eq story
    end

    it 'marks the association as changed when the association is changed' do
      image.story = story
      image.story_changed?.should eq true
    end

    it 'clears out the dirty association after commit' do
      image.story = story
      image.story_changed?.should eq true
      image.save!
      image.story_changed?.should eq false
    end

    it "creates a new version when setting the association" do
      image.story = story
      image.save!

      image.versions.count.should eq 2
      version = image.versions.order('version_number').last
      version.object_changes["story"][0].should eq Hash[]

      version.object_changes["story"][1].should eq Hash[{
        "headline" => "Headline",
        "body" => "Body"
      }]
    end

    it 'makes a version when removing' do
      image.story = story
      image.save!
      image.versions.count.should eq 2

      image.story = nil
      image.save!
      image.versions.count.should eq 3

      versions = image.versions.order('version_number').to_a
      versions.last.object_changes["story"][0].should eq Hash[{
        "headline" => "Headline",
        "body" => "Body"
      }]
      versions.last.object_changes["story"][1].should eq Hash[]
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        image.story_changed?.should eq false
        image.story = story
        image.story_changed?.should eq true
      end

      it 'is false after the parent object has been saved' do
        image.story = story
        image.story_changed?.should eq true
        image.save!
        image.story_changed?.should eq false
      end

      it 'is false if the association has not changed' do
        pending "single associations save versions even if not changed"

        image.story = story
        image.story_changed?.should eq true
        image.save!
        image.story_changed?.should eq false

        image.story = story
        image.story_changed?.should eq false
      end

      it 'is true when switching to or from nil' do
        # image.story is nil
        image.story = story
        image.story_changed?.should eq true
        image.save!

        image.story = nil
        image.story_changed?.should eq true
      end
    end
  end
end
