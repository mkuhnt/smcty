require 'smcty/job'

module Smcty
  class Scheduling

    def initialize(configuration)
      @configuration = configuration
      @projects = {}
    end

    def plan_project(project)
      jobs = []
      @projects[project] = jobs

      # 1. split the requirements into jobs
      project.resources.each do |r|
        project.amount(r).times do
          jobs << Job.new(r)
        end
      end

      # 2. work through initial job list and either
      #   - allocate available resources
      #   - add jobs to produce dependent jobs
      # and iterate until the list does not change any more.
      #
      prev_size = 0
      while (jobs.size != prev_size) do
        prev_size = jobs.size
        jobs.select{|j| j.new? }.each do |job|
          allocation = store.allocate(job.resource, 1)
          if allocation
            job.allocate(allocation)
          else
            job.resource.dependent_resources.each do |dr|
              job.resource.dependent_resource_amount(dr).times do
                djob = Job.new(dr)
                job.add_dependent(djob)
                jobs << djob
              end
            end
          end
        end
      end
    end

    def next
      # any project finished?
      action = project_ready
      return action if action
      # any pure request?
      action = something_pure_to_produce
      return action if action
      # anything to pickup?
      action = something_to_pick
      return action if action
      # anything that can be produced?
      action = something_dependent_to_produce
      if action
        return action
      else
        return "wait"
      end
    end

    def project_ready
      @projects.keys.each do |project|
        ready = true
        @projects[project].each do |job|
          unless job.allocated?
            ready = false
            break
          end
        end

        if ready
          finish_project(project)
          # we are done and the project can be finished.
          return "finish #{project.name}"
        end
      end
      nil
    end

    def finish_project(project)
      # get all the allocated resources
      @projects[project].each do |job|
        job.allocation.get
      end
      # remove the project from scheduling
      @projects.delete(project)
    end

    def something_pure_to_produce
      @projects.keys.each do |project|
        @projects[project].each do |job|
          if job.new?
            production = @configuration.factory_for(job.resource).produce(job.resource)
            if production
              job.produce(production)
              return "produce #{job.resource.name}"
            end
          end
        end
      end
      nil
    end

    def something_to_pick
      @projects.keys.each do |project|
        @projects[project].each do |job|
          if job.ready?
            @configuration.factory_for(job.resource).pick(job.production)
            store.put(job.resource, 1)
            job.allocate(store.allocate(job.resource, 1))
            return "pick #{job.resource.name}"
          end
        end
      end
      nil
    end

    def something_dependent_to_produce
      @projects.keys.each do |project|
        @projects[project].each do |job|
          if job.allocated_dependencies?
            # extract the requirements
            requirements = job.dependent_jobs.map{|j| j.allocation }
            # remove the dependent jobs
            job.dependent_jobs.each{|j| @projects[project].delete(j)}
            # reset the job dependency
            job.reset_dependent_jobs
            # produce the resource
            production = @configuration.factory_for(job.resource).produce(job.resource, requirements)
            if production
              job.produce(production)
              return "produce #{job.resource.name}"
            end
          end
        end
      end
      nil
    end

    # debugging
    def print_job_lists
      @projects.keys.each do |project|
        puts
        puts "Project: #{project.name}"
        puts ""
        @projects[project].each_with_index do |job, idx|
          puts "\t Step-#{idx} - #{job_line(job)}"
        end
        puts
      end
    end

    def job_line(job)
      "#{job.resource.name}: allocation: #{job.allocation} production: #{job.production} dependent: #{job.dependent_jobs.map{|j| j.resource.name}} new: #{job.new?} ready: #{job.ready?} allocated dependencies: #{job.allocated_dependencies?}"
    end
    # debugging

    def to_hash
      {
        projects: @projects.keys.map{|p| project_hash(p, @projects[p])}
      }
    end

    def project_hash(project, job_list)
      {
        "name" => project.name,
        "requirements" => project.resources.map{|r| {"resource" => r.name, "amount" => project.amount(r)}},
        "jobs" => job_list.map{|j| j.to_hash}
      }
    end

    private

    def store
      @configuration.store
    end

  end
end
