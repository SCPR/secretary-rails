module Secretary
  class NotVersionedError < StandardError
    def initialize(klass=nil)
      @klass = klass
    end

    def message
      "Can't track an association on an unversioned model " \
      "(#{@klass}) Did you declare `has_secretary` first?"
    end
  end


  class NoAssociationError < StandardError
    def initialize(name=nil, klass=nil)
      @name   = name
      @klass  = klass
    end

    def message
      "There is no association named #{@name} for the class #{@klass}. " \
      "Check that you've already declared the association before calling " \
      "'tracks_association', and that you use symbols."
    end
  end
end
