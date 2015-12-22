module Smcty
  class Job
    attr_reader :resource, :project, :allocation

    def initialize(resource, project)
      @resource = resource
      @project = project
      @used = false
    end

    def new?
      true
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
