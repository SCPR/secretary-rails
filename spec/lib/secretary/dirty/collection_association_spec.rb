require 'spec_helper'

describe Secretary::Dirty::CollectionAssociation do
  let(:person) { create :person }
  let(:animal) { create :animal, name: "Bob", color: "dog" }

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
    animal  = build :animal, name: "Bryan", color: 'lame'

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
    animal  = build :animal, name: "Bryan", color: 'lame'
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
