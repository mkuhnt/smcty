require 'json'

require 'smcty/store'
require 'smcty/configuration'
require 'smcty/factory'
require 'smcty/resource'

module Smcty
  class Configurator
    attr_reader :configuration

    def initialize(config_path)
      @config_path = config_path
      @configuration = Configurator.read_configuration(config_path)
    end

    def save
      Configurator.write_configuration(@configuration, @config_path)
    end

    def self.read_configuration(path)
      file = File.read(path)
      data_hash = JSON.parse(file)

      if (data_hash && data_hash != {})
        store_hash = read_value(data_hash, "store", true)
        store_name = read_value(store_hash, "name", true)
        store_capacity = read_value(store_hash, "capacity", true)
        store = Store.new(store_name, store_capacity)

        configuration = Configuration.new(store)

        deferred_dependencies = []

        factories_list = read_value(data_hash, "factories", true)
        factories_list.each do |factory_hash|
          factory_name = read_value(factory_hash, "name", true)
          factory_capacity = read_value(factory_hash, "capacity", true)

          factory = Factory.new(factory_name, factory_capacity)
          configuration.register_factory(factory)

          factory_resources = read_value(factory_hash, "resources", true)
          factory_resources.each do |resources_hash|
            resource_name = read_value(resources_hash, "name", true)
            resource_description = read_value(resources_hash, "description", true)
            resource_time = read_value(resources_hash, "time", true)

            resource = Resource.new(resource_name, resource_description)
            factory.register_resource(resource, resource_time)

            resource_deps = read_value(resources_hash, "deps", false, [])
            resource_deps.each do |dependency_hash|
              dependency_name = read_value(dependency_hash, "name", true)
              dependency_amount = read_value(dependency_hash, "amount", true)

              if dep_resource = configuration.resource_by_name(dependency_name)
                resource.register_dependency(dep_resource, dependency_amount)
              else
                deferred_dependencies << {resource: resource,
                  dependency_name: dependency_name,
                  dependency_amount: dependency_amount
                }
              end
            end
          end
        end

        # post process deferred dependencies
        deferred_dependencies.each do |deferred_dep|
          resource = deferred_dep[:resource]
          dependency_name = deferred_dep[:dependency_name]
          amount = deferred_dep[:dependency_amount]

          dependent_resource = configuration.resource_by_name(dependency_name)
          unless dependent_resource
            raise "Cannot fullfill dependency from #{resource.name} -> #{dependency_name}"
          end

          resource.register_dependency(dependent_resource, amount)
        end

        # post process stock of store
        read_value(store_hash, "stock", false, []).each do |stock_hash|
          resource_name = read_value(stock_hash, "name", true)
          resource_amount = read_value(stock_hash, "amount", true)

          resource = configuration.resource_by_name(resource_name) || Resource.new(resource_name, "unmanaged")
          store.put(resource, resource_amount)
        end

        # post process the scheduling information
        scheduling_hash = read_value(data_hash, "scheduling", true)
        read_value(scheduling_hash, "projects", false, []).each do |project_hash|
          project_name = read_value(project_hash, "name", true)
          project = Project.new(project_name)
          read_value(project_hash, "requirements", true).each do |req|
            resource_name = read_value(req, "resource", true)
            amount = read_value(req, "amount", true).to_i
            resource = configuration.resource_by_name(resource_name)
            unless resource
              raise "Cannot register requirement for unknown resource #{resource_name}"
            end
            project.add_requirement(resource, amount)
          end

          job_dict = {}
          job_dependencies = {}
          jobs = []

          # first pass to create the single jobs
          read_value(project_hash, "jobs", true).each do |job_hash|
            reference = read_value(job_hash, "id", true)
            resource_name = read_value(job_hash, "resource", true)
            resource = configuration.resource_by_name(resource_name)
            unless resource
              raise "Cannot create job for unknown resource #{resource_name}"
            end
            job = Job.new(resource)
            job_dict[reference] = job
            jobs << job

            allocation_hash = read_value(job_hash, "allocation", false, nil)
            if allocation_hash
              amount = read_value(allocation_hash, "amount", true).to_i
              allocation = store.load_allocation(resource, amount)
              job.allocate(allocation) if allocation
            end

            production_hash = read_value(job_hash, "production", false, nil)
            if production_hash
              start_time = read_value(production_hash, "start_time", true).to_i
              duration = read_value(production_hash, "duration", true).to_i
              production = Production.new(resource, duration, start_time)
              job.produce(production)
            end

            dependency_list = read_value(job_hash, "dependent_jobs", false, nil)
            job_dependencies[job] = dependency_list if dependency_list
          end

          # second pass to connect dependent jobs
          job_dependencies.keys.each do |job|
            job_dependencies[job].each do |dep_ref|
              dep_job = job_dict[dep_ref]
              unless dep_job
                raise "job references another job which is not known (#{dep_ref})"
              end
              job.add_dependent(dep_job)
            end
          end

          configuration.scheduler.load_project(project, jobs)
        end

        configuration
      end
    end

    def self.write_configuration(configuration, path)
      File.open(path,"w") do |f|
        f.write(configuration.to_hash.to_json)
      end
    end

    private

    def self.read_value(hash, key, force, default=nil)
      value = hash[key]
      if force && (value == nil)
        raise "The hash #{hash} does not contain the key #{key}"
      end
      value || default
    end

  end
end
