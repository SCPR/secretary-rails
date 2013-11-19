## 1.0.0beta5
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
