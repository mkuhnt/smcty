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
      @production = nil
    end

    def produce(production)
      @allocation = nil
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

    def to_hash
      core_hash = {
        "id" => self.object_id,
        "resource" => @resource.name,
      }
      core_hash["allocation"] = @allocation.to_hash if @allocation
      core_hash["production"] = @production.to_hash if @production
      core_hash["dependent_jobs"] = @dependent_jobs.map{|j| j.object_id} if @dependent_jobs.size > 0
      core_hash
    end

  end
end
