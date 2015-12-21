module Smcty
  class Project
    attr_reader :label

    def initialize(label)
      @label = label
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
