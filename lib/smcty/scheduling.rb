# project add #label [#resource_name:#amount]+
#
# => Project ---> Requirements
#

# Job
# ---
#   j1 - resource, amount, project
#   j2 - resource, amount, project
#

class Smcty::Scheduling

  def initialize
    @jobs = []
    @allocations = {}
  end

  def register_project(project)
    project.resources.each do |res|
      @jobs << Job.new(res, project.amount(res), project)
    end
  end

  def next
    #
    # (1) try to allocate new jobs
    @jobs.select{|j| j.for_allocation}.each do |job|
      allocation = @store.allocate(job.resource, job.amount)
      job.allocate(allocation)
      # we need to arrane the preconditions
      unless allocation
        job.resource.dependent_resources.each do |res|
          @jobs << Job.new(res, job.resource.dependent_resource_amount, job.project)
        end
      end
    end
    #
    # (2) check if we have the preconditions for prodution (in the context of its project)
    @jobs.select{|j| j.for_production}.each do |job|
      precond = false
      precond_jobs = []
      job.dependent_resources.each do |dr|
        @jobs.select{|j| j.project == job.project && j.allocated?}.each do |aj|


        end
      end
      # use the preconditions if sufficient
      if precond
        precond_jobs.each do |pj|
          @store.get_allocation(pj.allocation)
          pj.use!
        end
        # create production task

      end

    end
  end

end

class Smcty::Job
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
