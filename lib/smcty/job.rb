module Smcty
  class Job
    attr_reader :resource

    def initialize(resource)
      @resource = resource
      @used = false
    end

    def allocate(allocation)
      @allocation = allocation
    end

    def produce(production)
      @production = production
    end

    def status
      if @allocation && @allocation.valid?
        return :allocated
      elsif @production && !@production.finished?
        return :in_production
      elsif @production && @production.finished?
        return :ready
      else
        return :new
      end
    end
  end
end
