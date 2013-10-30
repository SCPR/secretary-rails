class Secretary::NotVersionedError < StandardError
  def initialize(klasses=nil)
    @klasses = Array(klasses)
  end

  def message
    "Can't track an association on an unversioned model " \
    "(#{@klasses.join(", ")}) Did you declare `has_secretary` first?"
  end
end
