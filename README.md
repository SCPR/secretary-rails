# Secretary

#### A note about the Gem name
There is another gem called [`secretary`](http://rubygems.org/gems/secretary),
which hasn't been updated since 2008 and is obsolete. This gem is called
`secretary-rails` since `secretary` is already taken on RubyGems. However, the
module name is the same, so using them together would be difficult.


### What is it?
Light-weight model versioning for ActiveRecord. Works with Rails 3 and 4.


### How does it work?
Whenever you save your model, a new version is saved. The changes are
serialized and stored in the database, along with a version description,
foreign keys to the object, and a foreign key to the user who saved the object.


### Why is it better than [other versioning gem]?
* It tracks associations.
* It provides diffs (using the [`diffy`](http://rubygems.org/gems/diffy) gem).
* It only stores the changes, not the whole object.
* It is simple.


## Installation
Add to your gemfile:

```ruby
gem 'secretary-rails'
```

Run the setup command, which will create a migration to add the `versions`
table, and then run it:

```
bundle exec rake secretary:setup
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
per-model basis by using one of two methods:

```ruby
class Article < ActiveRecord::Base
  has_secretary

  # Included
  self.versioned_attributes = ["headline", "body"]
end
```

```ruby
class Article < ActiveRecord::Base
  has_secretary

  # Excluded
  self.unversioned_attributes = ["published_at", "is_editable"]
end
```

By default, `versioned_attributes` is the model's column names, minus the
globally configured `ignored_attributes`, minus any `unversioned_attributes`
you have set. `tracks_association` adds those associations to the
`versioned_attributes` array.


### Contributing
Fork it and send a pull request!
