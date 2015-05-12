require 'spec_helper'

describe "Dirty Collection Association" do
  describe 'has_many' do
    let(:person) { create :person }
    let(:animal) { create :animal, :name => "Bob", :color => "dog" }

    it 'sets associations_were' do
      person.animals << animal
      expect(person.animals_were).to eq []
    end

    it 'marks the association as changed when the association is changed' do
      person.animals << animal
      expect(person.animals_changed?).to eq true
    end

    it 'clears out the dirty association after commit' do
      person.animals << animal
      expect(person.animals_changed?).to eq true
      person.save!
      expect(person.animals_changed?).to eq false
    end

    it "creates a new version when adding" do
      person.animals = [animal]
      person.save!

      expect(person.versions.count).to eq 2
      version = person.versions.last
      expect(version.object_changes["animals"][0]).to eq []

      expect(version.object_changes["animals"][1]).to eq [
        {"name" => "Bob", "color" => "dog"}
      ]
    end

    it 'makes a version when adding' do
      person  = create :person
      animal  = build :animal, :name => "Bryan", :color => 'lame'

      person.animals << animal
      person.save!
      expect(person.versions.count).to eq 2

      versions = person.versions.order('version_number').to_a
      expect(versions.last.object_changes["animals"][0]).to eq []
      expect(versions.last.object_changes["animals"][1]).to eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
    end

    it 'makes a version when removing' do
      person  = build :person
      animal  = build :animal, :name => "Bryan", :color => 'lame'
      person.animals = [animal]
      person.save!
      expect(person.versions.count).to eq 1

      person.animals = []
      person.save!
      expect(person.versions.count).to eq 2

      versions = person.versions.order('version_number').to_a
      expect(versions.last.object_changes["animals"][0]).to eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
      expect(versions.last.object_changes["animals"][1]).to eq []
    end


    context 'with accepts_nested_attributes_for' do
      it 'adds a new version when adding to collection' do
        animals_attributes = [
          {
            "name" => "George",
            "color" => "yes"
          }
        ]

        person.animals_attributes = animals_attributes
        expect(person.animals_were).to eq []
        person.save!
        expect(person.versions.count).to eq 2

        version = person.versions.order('version_number').last
        expect(version.object_changes["animals"][0]).to eq []
        expect(version.object_changes["animals"][1]).to eq [{
          "name" => "George",
          "color" => "yes"
        }]
      end

      it 'adds a new version when changing something in collection' do
        animals_attributes = [
          {
            "id" => animal.id,
            "name" => "Lemon"
          }
        ]

        person.animals << animal
        person.save!
        expect(person.versions.count).to eq 2
        person.animals_attributes = animals_attributes
        person.save!
        expect(person.versions.count).to eq 3

        version = person.versions.order('version_number').last
        expect(version.object_changes["animals"][0]).to eq [{
          "name" => "Bob",
          "color" => "dog"
        }]
        expect(version.object_changes["animals"][1]).to eq [{
          "name" => "Lemon",
          "color" => "dog"
        }]
      end

      it 'adds a new version when removing something from collection' do
        animals_attributes = [
          {
            "id" => animal.id,
            "_destroy" => "1"
          }
        ]

        person.animals << animal
        person.save!
        expect(person.versions.count).to eq 2
        person.animals_attributes = animals_attributes
        person.save!
        expect(person.versions.count).to eq 3

        version = person.versions.order('version_number').last
        expect(version.object_changes["animals"][0]).to eq [{
          "name" => "Bob",
          "color" => "dog"
        }]
        expect(version.object_changes["animals"][1]).to eq []
      end

      it 'does not add a new version if nothing has changed' do
        animals_attributes = [
          {
            "id" => animal.id,
            "name" => "Bob"
          }
        ]

        person.animals << animal
        person.save!
        expect(person.versions.count).to eq 2
         # this doesn't call before_add/remove callbacks
        person.animals_attributes = animals_attributes
        person.save!
        expect(person.versions.count).to eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        expect(person.animals_changed?).to eq false
        person.animals << animal
        expect(person.animals_changed?).to eq true
      end

      it 'is false after the parent object has been saved' do
        person.animals << animal
        expect(person.animals_changed?).to eq true
        person.save!
        expect(person.animals_changed?).to eq false
      end

      it 'is false if the association has not changed' do
        person.animals << animal
        expect(person.animals_changed?).to eq true
        person.save!
        expect(person.animals_changed?).to eq false

        person.animals = [animal]
        expect(person.animals_changed?).to eq false
      end
    end
  end


  describe 'has_and_belongs_to_many' do
    let(:car) { create :car }
    let(:location) {
      create :location, :title => "Home", :address => "123 Fake St."
    }

    it 'sets associations_were' do
      car.locations << location
      expect(car.locations_were).to eq []
    end

    it 'marks the association as changed when the association is changed' do
      car.locations << location
      expect(car.locations_changed?).to eq true
    end

    it 'clears out the dirty association after commit' do
      car.locations << location
      expect(car.locations_changed?).to eq true
      car.save!
      expect(car.locations_changed?).to eq false
    end

    it "creates a new version when adding" do
      car.locations = [location]
      car.save!

      expect(car.versions.count).to eq 2
      version = car.versions.last
      expect(version.object_changes["locations"][0]).to eq []

      expect(version.object_changes["locations"][1]).to eq [
        {"title" => "Home", "address" => "123 Fake St."}
      ]
    end

    it 'makes a version when adding' do
      car.locations << location
      car.save!
      expect(car.versions.count).to eq 2

      versions = car.versions.order('version_number').to_a
      expect(versions.last.object_changes["locations"][0]).to eq []
      expect(versions.last.object_changes["locations"][1]).to eq [{
        "title" => "Home",
        "address" => "123 Fake St."
      }]
    end

    it 'makes a version when removing' do
      car.locations = [location]
      car.save!
      expect(car.versions.count).to eq 2

      car.locations = []
      car.save!
      expect(car.versions.count).to eq 3

      versions = car.versions.order('version_number').to_a
      expect(versions.last.object_changes["locations"][0]).to eq [{
        "title" => "Home",
        "address" => "123 Fake St."
      }]
      expect(versions.last.object_changes["locations"][1]).to eq []
    end


    context 'with accepts_nested_attributes_for' do
      it 'adds a new version when adding to collection' do
        locations_attributes = [
          {
            "title" => "Work",
            "address" => "456 Real St."
          }
        ]

        car.locations_attributes = locations_attributes
        expect(car.locations_were).to eq []
        car.save!
        expect(car.versions.count).to eq 2

        version = car.versions.order('version_number').last
        expect(version.object_changes["locations"][0]).to eq []
        expect(version.object_changes["locations"][1]).to eq [{
          "title" => "Work",
          "address" => "456 Real St."
        }]
      end

      it 'adds a new version when changing something in collection' do
        locations_attributes = [
          {
            "id" => location.id,
            "title" => "Work"
          }
        ]

        car.locations << location
        car.save!
        expect(car.versions.count).to eq 2
        car.locations_attributes = locations_attributes
        car.save!
        expect(car.versions.count).to eq 3

        version = car.versions.order('version_number').last
        expect(version.object_changes["locations"][0]).to eq [{
          "title" => "Home",
          "address" => "123 Fake St."
        }]
        expect(version.object_changes["locations"][1]).to eq [{
          "title" => "Work",
          "address" => "123 Fake St."
        }]
      end

      it 'adds a new version when removing something from collection' do
        locations_attributes = [
          {
            "id" => location.id,
            "_destroy" => "1"
          }
        ]

        car.locations << location
        car.save!
        expect(car.versions.count).to eq 2
        car.locations_attributes = locations_attributes
        car.save!
        expect(car.versions.count).to eq 3

        version = car.versions.order('version_number').last
        expect(version.object_changes["locations"][0]).to eq [{
          "title" => "Home",
          "address" => "123 Fake St."
        }]
        expect(version.object_changes["locations"][1]).to eq []
      end

      it 'does not add a new version if nothing has changed' do
        locations_attributes = [
          {
            "id" => location.id,
            "title" => "Home"
          }
        ]

        car.locations << location
        car.save!
        expect(car.versions.count).to eq 2
         # this doesn't call before_add/remove callbacks
        car.locations_attributes = locations_attributes
        car.save!
        expect(car.versions.count).to eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        expect(car.locations_changed?).to eq false
        car.locations << location
        expect(car.locations_changed?).to eq true
      end

      it 'is false after the parent object has been saved' do
        car.locations << location
        expect(car.locations_changed?).to eq true
        car.save!
        expect(car.locations_changed?).to eq false
      end

      it 'is false if the association has not changed' do
        car.locations << location
        expect(car.locations_changed?).to eq true
        car.save!
        expect(car.locations_changed?).to eq false

        car.locations = [location]
        expect(car.locations_changed?).to eq false
      end
    end
  end


  describe 'has_many :through' do
    let(:story) { create :story }
    let(:user) { create :user, :name => "Bryan" }

    it "can track the join model" do
      # Github #14
      story = build :story
      user = build :user

      user.save!

      story.users << user
      story.save!

      version = story.versions.last
      expect(version.object_changes["story_users"][0]).to eq []
      expect(version.object_changes["story_users"][1][0]["story_id"]).to eq story.id
      expect(version.object_changes["story_users"][1][0]["user_id"]).to eq user.id
    end

    it 'sets associations_were' do
      story.users << user
      expect(story.users_were).to eq []
    end

    it 'marks the association as changed when the association is changed' do
      story.users << user
      expect(story.users_changed?).to eq true
    end

    it 'clears out the dirty association after commit' do
      story.users << user
      expect(story.users_changed?).to eq true
      story.save!
      expect(story.users_changed?).to eq false
    end

    it "creates a new version when adding" do
      story.users = [user]
      story.save!

      expect(story.versions.count).to eq 2
      version = story.versions.last
      expect(version.object_changes["users"][0]).to eq []

      expect(version.object_changes["users"][1]).to eq [
        {"name" => "Bryan"}
      ]
    end

    it 'makes a version when adding' do
      story.users << user
      story.save!
      expect(story.versions.count).to eq 2

      versions = story.versions.order('version_number').to_a
      expect(versions.last.object_changes["users"][0]).to eq []
      expect(versions.last.object_changes["users"][1]).to eq [{
        "name" => "Bryan"
      }]
    end

    it 'makes a version when removing' do
      story.users = [user]
      story.save!
      expect(story.versions.count).to eq 2

      story.users = []
      story.save!
      expect(story.versions.count).to eq 3

      versions = story.versions.order('version_number').to_a
      expect(versions.last.object_changes["users"][0]).to eq [{
        "name" => "Bryan"
      }]
      expect(versions.last.object_changes["users"][1]).to eq []
    end


    context 'with accepts_nested_attributes_for' do
      it 'adds a new version when adding to collection' do
        users_attributes = [
          {
            "name" => "Stephen"
          }
        ]

        story.users_attributes = users_attributes
        expect(story.users_were).to eq []
        story.save!
        expect(story.versions.count).to eq 2

        version = story.versions.order('version_number').last
        expect(version.object_changes["users"][0]).to eq []
        expect(version.object_changes["users"][1]).to eq [{
          "name" => "Stephen"
        }]
      end

      it 'adds a new version when changing something in collection' do
        users_attributes = [
          {
            "id" => user.id,
            "name" => "Stephen"
          }
        ]

        story.users << user
        story.save!
        expect(story.versions.count).to eq 2
        story.users_attributes = users_attributes
        story.save!
        expect(story.versions.count).to eq 3

        version = story.versions.order('version_number').last
        expect(version.object_changes["users"][0]).to eq [{
          "name" => "Bryan"
        }]
        expect(version.object_changes["users"][1]).to eq [{
          "name" => "Stephen"
        }]
      end

      it 'adds a new version when removing something from collection' do
        users_attributes = [
          {
            "id" => user.id,
            "_destroy" => "1"
          }
        ]

        story.users << user
        story.save!
        expect(story.versions.count).to eq 2
        story.users_attributes = users_attributes
        story.save!
        expect(story.versions.count).to eq 3

        version = story.versions.order('version_number').last
        expect(version.object_changes["users"][0]).to eq [{
          "name" => "Bryan"
        }]
        expect(version.object_changes["users"][1]).to eq []
      end

      it 'does not add a new version if nothing has changed' do
        users_attributes = [
          {
            "id" => user.id,
            "name" => "Bryan"
          }
        ]

        story.users << user
        story.save!
        expect(story.versions.count).to eq 2
         # this doesn't call before_add/remove callbacks
        story.users_attributes = users_attributes
        story.save!
        expect(story.versions.count).to eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        expect(story.users_changed?).to eq false
        story.users << user
        expect(story.users_changed?).to eq true
      end

      it 'is false after the parent object has been saved' do
        story.users << user
        expect(story.users_changed?).to eq true
        story.save!
        expect(story.users_changed?).to eq false
      end

      it 'is false if the association has not changed' do
        story.users << user
        expect(story.users_changed?).to eq true
        story.save!
        expect(story.users_changed?).to eq false

        story.users = [user]
        expect(story.users_changed?).to eq false
      end
    end
  end
end
