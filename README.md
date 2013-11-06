# Secretary

[![Build Status](https://circleci.com/gh/SCPR/secretary-rails.png?circle-token=f1fadff9935d408e019bf9599b68aaf7a406d13b)](https://circleci.com/gh/SCPR/secretary-rails)

#### A note about the Gem name
There is another gem called [`secretary`](http://rubygems.org/gems/secretary),
which hasn't been updated since 2008 and is obsolete. This gem is called
`secretary-rails` since `secretary` is already taken on RubyGems. However, the
module name is the same, so using them together would be difficult.


### What is it?
Light-weight model versioning for ActiveRecord 3.2+.

### How does it work?
Whenever you save your model, a new version is saved. The changes are
serialized and stored in the database, along with a version description,
foreign keys to the object, and a foreign key to the user who saved the object.

### Why is it better than [other versioning gem]?
* It tracks associations.
* It provides diffs (using the [`diffy`](http://rubygems.org/gems/diffy) gem).
* It only stores the changes, not the whole object.
* It is simple.

### Compatibility
* Rails 3.2+
* SQLite
* MySQL? (untested)
* PostgreSQL? (untested)

### Dependencies
* [`activerecord`](http://rubygems.org/gems/activerecord) >= 3.2.0
* [`railties`](http://rubygems.org/gems/railties) >= 3.2.0
* [`diffy`](http://rubygems.org/gems/diffy) ~> 3.0.1


## Installation
Add to your gemfile:

```ruby
gem 'secretary-rails'
```

Run the install command, which will create a migration to add the `versions`
table, and then run the migration:

```
bundle exec rails generate secretary:install
bundle exec rake db:migrate
```


## Usage
Add the `has_secretary` macro to your model:

```ruby
class Article < ActiveRecord::Base
  has_secretary
end
```

Congratulations, now your records are being versioned.

### Tracking associations
This gem is built with the end-user in mind, so it doesn't track hidden
associations (i.e. join models). However, you can tell it to track associated
objects WITHIN their parent object's version by using the `tracks_association`
macro. For example:

```ruby
class Author < ActiveRecord::Base
  has_many :article_authors
  has_many :articles, through: :article_authors
end

class ArticleAuthor < ActiveRecord::Base
  belongs_to :article
  belongs_to :author
end

class Article < ActiveRecord::Base
  has_secretary

  has_many :article_authors
  has_many :authors, through: :article_authors
  tracks_association :authors
end
```

Now, when you save an `Article`, a new version won't be created for the
new `ArticleAuthor` object(s). Instead, an array will be added to the `Article`'s
changes, which will include the information about the author(s).

You can also pass in multiple association names into `tracks_association`.

This also works on all other association types in the same way:
* has_many
* has_many :through
* has_and_belongs_to_many
* has_one
* belongs_to

### Dirty Associations
Secretary provides Rails-style `dirty attributes` for associations.
Given an association `has_many :pets`, the methods available are:

* **pets_changed?**
* **pets_were**

Secretary also merges in the association changes into the standard Rails
`changes` hash:

```ruby
person.pets.to_a # => []

person.pets << Pet.new(name: "Spot")

person.pets_changed? # => true
person.changed?      # => true
person.pets_were     # => []
person.changes       # => { "pets" => [[], [{ "name" => "Spot" }]]}
```

### Tracking Users
A version has an association to a user object, which tells you who created that
version. The logged user is an attribute on the object being changed, so you
can add it in via the controller:

```ruby
class ArticlesController < ApplicationControler
  before_filter :get_object, only: [:show, :edit, :update, :destroy]
  before_filter :inject_logged_user, only: [:update]

  def create
    @article = Article.new(article_params)
    inject_logged_user
    # ...
  end

  # ...

  private

  def get_object
    @article = Article.find(params[:id])
  end

  def inject_logged_user
    @article.logged_user_id = @current_user.id
  end
end
```

### Viewing Diffs
The `Secretary::Version` model allows you to see unix-style diffs of the
changes, using the [`diffy`](http://rubygems.org/gems/diffy) gem. The diffs
are represented as a hash, where the key is the name of the attribute, and the
value is the `Diffy::Diff` object.

```ruby
article = Article.new(headline: "Old Headline", body: "Lorem ipsum...")
article.save

article.update_attributes(headline: "Updated Headline", body: "Updated Body")

last_version = article.versions.last
puts last_version.attribute_diffs

{"headline"=>
  -Old Headline
\ No newline at end of file
+Updated Headline
\ No newline at end of file
,
 "body"=>
  -Lorem ipsum...
\ No newline at end of file
+Updated Body
\ No newline at end of file
}
```

This is just the simple text representation of the `Diffy::Diff` objects.
Diffy also provides several other output formats. See
[diffy's README](https://github.com/samg/diffy/tree/master) for more options.

### Configuration
In an initializer (may we suggest `secretary.rb`?), add:

```ruby
# This is a list of all the possible configurations and their defaults.
Secretary.configure do |config|
  config.user_class         = "::User"
  config.ignored_attributes = ["id", "created_at", "updated_at"]
end
```

* **user_class** - The class for your user model.
* **ignored_attributes** - The attributes which should always be ignored
  when generating a version, for every model, as an array of Strings.

### Specifying which attributes to keep track of
Sometimes you have an attribute on your model that either isn't public
(not in the form), or you just don't want to version. You can tell Secretary
to ignore these attributes globally by setting
`Secretary.config.ignore_attributes`. You can also ignore attributes on a
per-model basis by using one of two options:

**NOTE** The attributes *must* be specified as Strings.

```ruby
class Article < ActiveRecord::Base
  # Inclusion
  has_secretary on: ["headline", "body"]
end
```

```ruby
class Article < ActiveRecord::Base
# Exclusion
  has_secretary except: ["published_at", "is_editable"]
end
```

By default, the versioned attributes are: the model's column names, minus the
globally configured `ignored_attributes`, minus any excluded attributes
you have set.

Using `tracks_association` adds those associations to the
`versioned_attributes` array:

```ruby
class Article < ActiveRecord::Base
  has_secretary on: ["headline"]

  has_many :images
  tracks_association :images
end

Article.versioned_attributes # => ["headline", "images"]
``` 


## Contributing
Fork it and send a pull request!

### TODO
* See [Issues](https://github.com/SCPR/secretary-rails/issues).
* Associations are only tracked one-level deep, It would be nice to also
  track the changes of the association (i.e. recognize when an associated
  object was changed and show its changed, instead of just showing a whole
  new object).

### Running Tests
This library uses [appraisal](https://github.com/thoughtbot/appraisal) to test
against different Rails versions. To run the test suite on all versions, use
`appraisal rspec`.
