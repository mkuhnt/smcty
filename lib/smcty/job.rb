module Smcty
  class Job
    attr_reader :resource, :amount, :project, :allocation

    def initialize(resource, amount, project)
      @resource = resource
      @amount = amount
      @project = project
      @used = false
    end

    def allocate(allocation)
      @allocation = allocation
    end

    def allocated?
      @allocation != nil
    end

    def for_allocation
      @allocation == nil
    end

    def for_production
      @production == nil && @allocation == nil
    end

    def use!
      @used = true
    end

    def used?
      @used
    end

  end
end
