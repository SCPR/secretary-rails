## 1.1.2 (TBD)
#### Changes
* Better dependency declarations


## 1.1.1 (2014-05-07)
#### Fixes
* Forces callbacks into an array before trying to add Secretary callbacks. This fixes compatibility with `ar-octopus` library.
* Fixed an error where `tracks_association` was raising `NotImplementError` if `:dependent` was defined on the association. ([#12](https://github.com/SCPR/secretary-rails/issues/12))
* Fixes migration-copy generator.

#### Additions
* Now being tested with Rails 4-1-stable and 4-2-head


## 1.1.0 (2014-03-19)
#### Changes
* Humanized attributes in Version Description.
* Activities association is now added to the User class automatically.

#### Fixes
* Automatically add the foreign key to versioned attributes for a belongs_to
  association. Before, it was only adding the association name, which caused
  a version not to be created when updating a belongs_to association via a form
  if the foreign key wasn't in the `versioned_attributes` list.
* Fixed migration generator
* Fixes bug where db:schema:load couldn't run if the user class specified versioned attributes.


## 1.0.0
#### Fixes
* Only add an attribute to `versioned_changes` if it changed significantly.
  This fixes the problem where a `has_one` association was creating a version
  no matter what.

#### Changes
* Use memoized `versioned_changes` in callbacks for performance optimization.
* Only create a version if `versioned_changes` is present. The previous
  behavior was to create a version if `changed?` was true, which was creating
  empty versions (because `changed?` could be true for an attribute that we're
  not versioning)


## 1.0.0.beta5
#### Fixes
* Make sure assigning nested attributes only makes the model dirty for tracked
  associations.
* Fixed error where adding an inherited class to a collection association.
* Rescue when assigning nested attributes so that `db:schema:load` can be
  called properly.

#### Changes
* `#versioned_attributes=` will now raise an error if you pass it anything but
  an array of strings. This is to prevent someone from passing in symbols
  and getting subtle bugs.


## 1.0.0.beta4
#### Changes
* [BREAKING] Remove custom_changes, instead we're just using the
  ActiveModel::Dirty interface.


## 1.0.0.beta3
#### Additions
* A bunch of additional tests for:
  * has_many :through
  * has_and_belongs_to_many
  * MySQL
  * PostgreSQL
* Lots of additional documentation

#### Changes
* Refactored some code to clean up has_secretary module. Moved Dirty Attribute
  methods into their own module, where (eventually) the full ActiveModel::Dirty
  API will be implemented for associations as well.


## 1.0.0.beta2
#### Additions
* Added better way to declare attribute inclusion/exclusion:
  `has_secretary on: []` and `has_secretary except: []`. This ensures that
  attributes will be declared before any `tracks_association` are called.
* Added support for singular associations tracking (has_one, belongs_to)
* Added support for Rails 4.1 (edge)


## 1.0.0.beta1
* Beta for stable 1.0 release.


## 0.0.1
* Initial release
