require 'spec_helper'

describe Secretary::Dirty::CollectionAssociation do
  describe 'has_many' do
    let(:person) { create :person }
    let(:animal) { create :animal, :name => "Bob", :color => "dog" }

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

    it "creates a new version when adding" do
      person.animals = [animal]
      person.save!

      person.versions.count.should eq 2
      version = person.versions.last
      version.object_changes["animals"][0].should eq []

      version.object_changes["animals"][1].should eq [
        {"name" => "Bob", "color" => "dog"}
      ]
    end

    it 'makes a version when adding' do
      person  = create :person
      animal  = build :animal, :name => "Bryan", :color => 'lame'

      person.animals << animal
      person.save!
      person.versions.count.should eq 2

      versions = person.versions.order('version_number').to_a
      versions.last.object_changes["animals"][0].should eq []
      versions.last.object_changes["animals"][1].should eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
    end

    it 'makes a version when removing' do
      person  = build :person
      animal  = build :animal, :name => "Bryan", :color => 'lame'
      person.animals = [animal]
      person.save!
      person.versions.count.should eq 1

      person.animals = []
      person.save!
      person.versions.count.should eq 2

      versions = person.versions.order('version_number').to_a
      versions.last.object_changes["animals"][0].should eq [{
        "name" => "Bryan",
        "color" => "lame"
      }]
      versions.last.object_changes["animals"][1].should eq []
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
        person.animals_were.should eq []
        person.save!
        person.versions.count.should eq 2

        version = person.versions.order('version_number').last
        version.object_changes["animals"][0].should eq []
        version.object_changes["animals"][1].should eq [{
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
        person.versions.count.should eq 2
        person.animals_attributes = animals_attributes
        person.save!
        person.versions.count.should eq 3

        version = person.versions.order('version_number').last
        version.object_changes["animals"][0].should eq [{
          "name" => "Bob",
          "color" => "dog"
        }]
        version.object_changes["animals"][1].should eq [{
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
        person.versions.count.should eq 2
        person.animals_attributes = animals_attributes
        person.save!
        person.versions.count.should eq 3

        version = person.versions.order('version_number').last
        version.object_changes["animals"][0].should eq [{
          "name" => "Bob",
          "color" => "dog"
        }]
        version.object_changes["animals"][1].should eq []
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
        person.versions.count.should eq 2
         # this doesn't call before_add/remove callbacks
        person.animals_attributes = animals_attributes
        person.save!
        person.versions.count.should eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        person.animals_changed?.should eq false
        person.animals << animal
        person.animals_changed?.should eq true
      end

      it 'is false after the parent object has been saved' do
        person.animals << animal
        person.animals_changed?.should eq true
        person.save!
        person.animals_changed?.should eq false
      end

      it 'is false if the association has not changed' do
        person.animals << animal
        person.animals_changed?.should eq true
        person.save!
        person.animals_changed?.should eq false

        person.animals = [animal]
        person.animals_changed?.should eq false
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
      car.locations_were.should eq []
    end

    it 'marks the association as changed when the association is changed' do
      car.locations << location
      car.locations_changed?.should eq true
    end

    it 'clears out the dirty association after commit' do
      car.locations << location
      car.locations_changed?.should eq true
      car.save!
      car.locations_changed?.should eq false
    end

    it "creates a new version when adding" do
      car.locations = [location]
      car.save!

      car.versions.count.should eq 2
      version = car.versions.last
      version.object_changes["locations"][0].should eq []

      version.object_changes["locations"][1].should eq [
        {"title" => "Home", "address" => "123 Fake St."}
      ]
    end

    it 'makes a version when adding' do
      car.locations << location
      car.save!
      car.versions.count.should eq 2

      versions = car.versions.order('version_number').to_a
      versions.last.object_changes["locations"][0].should eq []
      versions.last.object_changes["locations"][1].should eq [{
        "title" => "Home",
        "address" => "123 Fake St."
      }]
    end

    it 'makes a version when removing' do
      car.locations = [location]
      car.save!
      car.versions.count.should eq 2

      car.locations = []
      car.save!
      car.versions.count.should eq 3

      versions = car.versions.order('version_number').to_a
      versions.last.object_changes["locations"][0].should eq [{
        "title" => "Home",
        "address" => "123 Fake St."
      }]
      versions.last.object_changes["locations"][1].should eq []
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
        car.locations_were.should eq []
        car.save!
        car.versions.count.should eq 2

        version = car.versions.order('version_number').last
        version.object_changes["locations"][0].should eq []
        version.object_changes["locations"][1].should eq [{
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
        car.versions.count.should eq 2
        car.locations_attributes = locations_attributes
        car.save!
        car.versions.count.should eq 3

        version = car.versions.order('version_number').last
        version.object_changes["locations"][0].should eq [{
          "title" => "Home",
          "address" => "123 Fake St."
        }]
        version.object_changes["locations"][1].should eq [{
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
        car.versions.count.should eq 2
        car.locations_attributes = locations_attributes
        car.save!
        car.versions.count.should eq 3

        version = car.versions.order('version_number').last
        version.object_changes["locations"][0].should eq [{
          "title" => "Home",
          "address" => "123 Fake St."
        }]
        version.object_changes["locations"][1].should eq []
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
        car.versions.count.should eq 2
         # this doesn't call before_add/remove callbacks
        car.locations_attributes = locations_attributes
        car.save!
        car.versions.count.should eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        car.locations_changed?.should eq false
        car.locations << location
        car.locations_changed?.should eq true
      end

      it 'is false after the parent object has been saved' do
        car.locations << location
        car.locations_changed?.should eq true
        car.save!
        car.locations_changed?.should eq false
      end

      it 'is false if the association has not changed' do
        car.locations << location
        car.locations_changed?.should eq true
        car.save!
        car.locations_changed?.should eq false

        car.locations = [location]
        car.locations_changed?.should eq false
      end
    end
  end


  describe 'has_many :through' do
    let(:story) { create :story }
    let(:user) { create :user, :name => "Bryan" }

    it 'sets associations_were' do
      story.users << user
      story.users_were.should eq []
    end

    it 'marks the association as changed when the association is changed' do
      story.users << user
      story.users_changed?.should eq true
    end

    it 'clears out the dirty association after commit' do
      story.users << user
      story.users_changed?.should eq true
      story.save!
      story.users_changed?.should eq false
    end

    it "creates a new version when adding" do
      story.users = [user]
      story.save!

      story.versions.count.should eq 2
      version = story.versions.last
      version.object_changes["users"][0].should eq []

      version.object_changes["users"][1].should eq [
        {"name" => "Bryan"}
      ]
    end

    it 'makes a version when adding' do
      story.users << user
      story.save!
      story.versions.count.should eq 2

      versions = story.versions.order('version_number').to_a
      versions.last.object_changes["users"][0].should eq []
      versions.last.object_changes["users"][1].should eq [{
        "name" => "Bryan"
      }]
    end

    it 'makes a version when removing' do
      story.users = [user]
      story.save!
      story.versions.count.should eq 2

      story.users = []
      story.save!
      story.versions.count.should eq 3

      versions = story.versions.order('version_number').to_a
      versions.last.object_changes["users"][0].should eq [{
        "name" => "Bryan"
      }]
      versions.last.object_changes["users"][1].should eq []
    end


    context 'with accepts_nested_attributes_for' do
      it 'adds a new version when adding to collection' do
        users_attributes = [
          {
            "name" => "Stephen"
          }
        ]

        story.users_attributes = users_attributes
        story.users_were.should eq []
        story.save!
        story.versions.count.should eq 2

        version = story.versions.order('version_number').last
        version.object_changes["users"][0].should eq []
        version.object_changes["users"][1].should eq [{
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
        story.versions.count.should eq 2
        story.users_attributes = users_attributes
        story.save!
        story.versions.count.should eq 3

        version = story.versions.order('version_number').last
        version.object_changes["users"][0].should eq [{
          "name" => "Bryan"
        }]
        version.object_changes["users"][1].should eq [{
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
        story.versions.count.should eq 2
        story.users_attributes = users_attributes
        story.save!
        story.versions.count.should eq 3

        version = story.versions.order('version_number').last
        version.object_changes["users"][0].should eq [{
          "name" => "Bryan"
        }]
        version.object_changes["users"][1].should eq []
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
        story.versions.count.should eq 2
         # this doesn't call before_add/remove callbacks
        story.users_attributes = users_attributes
        story.save!
        story.versions.count.should eq 2
      end
    end

    describe '#association_changed?' do
      it 'is true if the association has changed' do
        story.users_changed?.should eq false
        story.users << user
        story.users_changed?.should eq true
      end

      it 'is false after the parent object has been saved' do
        story.users << user
        story.users_changed?.should eq true
        story.save!
        story.users_changed?.should eq false
      end

      it 'is false if the association has not changed' do
        story.users << user
        story.users_changed?.should eq true
        story.save!
        story.users_changed?.should eq false

        story.users = [user]
        story.users_changed?.should eq false
      end
    end
  end
end
