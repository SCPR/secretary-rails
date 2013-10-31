FactoryGirl.define do
  factory :animal do
    name "Fred"
    species "Elephant"
    color "gray"
  end

  factory :location do
    title "Crawford Family Forum"
    address "474 S. Raymond, Pasadena"
  end

  factory :person do
    name "Bryan"
    ethnicity "none"
    age 100
  end

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
