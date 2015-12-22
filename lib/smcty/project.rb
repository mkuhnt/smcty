module Smcty
  class Project
    attr_reader :name

    def initialize(name)
      @name = name
      @requirements = {}
    end

    def resources
      @requirements.keys
    end

    def amount(resource)
      @requirements[resource]
    end

    def add_requirement(resource, amount)
      @requirements[resource] = amount
    end

  end
end
