FactoryGirl.define do
  factory :story do
    headline "Cool Headline"
    body "Lorem, etc."
  end

  factory :user do
    name "Bryan Ricker"
  end

  factory :version, class: "Secretary::Version" do
    versioned { |v| v.association :story }
    user
  end
end
