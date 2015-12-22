module Smcty
  class Job
    attr_reader :resource, :allocation, :production, :dependent_jobs

    def initialize(resource)
      @resource = resource
      @used = false
      @dependent_jobs = []
    end

    def allocate(allocation)
      @allocation = allocation
    end

    def produce(production)
      @production = production
    end

    def add_dependent(job)
      @dependent_jobs << job
    end

    def reset_dependent_jobs
      @dependent_jobs = []
    end

    def dependencies?
      @dependent_jobs.size > 0
    end

    def allocated?
      @allocation != nil
    end

    def in_production?
      @production != nil && !@production.finished?
    end

    def ready?
      @production != nil && @production.finished?
    end

    def new?
      @allocation == nil && @production == nil && @dependent_jobs.size == 0
    end

    def allocated_dependencies?
      if dependencies?
        @dependent_jobs.each do |job|
          return false unless job.allocated?
        end
        return true
      else
        return false
      end
    end

  end
end
