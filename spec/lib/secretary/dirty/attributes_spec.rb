require 'spec_helper'

describe Secretary::Dirty::Attributes do
  let(:other_story) {
    create :story,
      :headline         => "Cooler Story, Bro",
      :body             => "Some cooler text."
  }

  describe '#changes' do
    it 'is the built-in changes reverse-merged with custom changes' do
      story = create :story, :headline => "Original Headline"
      story.headline = "Updated Headline!"
      story.custom_changes['assets'] = [[], { :a => 1, :b => 2 }]

      story.changes.should eq Hash[{
        'headline' => ['Original Headline', "Updated Headline!"],
        'assets'   => [[], { 'a' => 1, 'b' => 2 }]
      }]
    end
  end


  describe '#changed?' do
    it 'checks if custom changes are present as well' do
      other_story.changed?.should eq false
      other_story.custom_changes['assets'] = [[], { :a => 1, :b => 2 }]
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
