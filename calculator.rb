require 'json'

require_relative "helpers"
require_relative "structures"
require_relative "output"

class Configuration
  attr_reader :created_at, :store

  def initialize(store)
    @created_at = Time.new
    @store = store
    @factories = {}
  end

  def register_factory(factory)
    @factories[factory.name] = factory
  end

  def resource_by_name(resource_name)
    @factories.values.each do |factory|
      resource = factory.resource_by_name(resource_name)
      return resource if resource
    end
    nil
  end

  def factories
    @factories.keys.sort
  end

  def factory(name)
    @factories[name]
  end

  def to_s
    "Configuration created at #{@created_at}"
  end

  def to_hash
    {
      "store": @store.to_hash,
      "factories": @factories.values.map{|f| f.to_hash}
    }
  end

end

def read_value(hash, key, force, default=nil)
  value = hash[key]
  if force && (value == nil)
    raise "The hash #{hash} does not contain the key #{key}"
  end
  value || default
end

def read_configuration(path)
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
        resource_time = read_value(resources_hash, "time", true)

        resource = Resource.new(resource_name)
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

      resource = configuration.resource_by_name(resource_name) || Resource.new(resource_name)
      store.put(resource, resource_amount)
    end

    configuration
  end
end

def write_configuration(configuration, path)
  File.open(path,"w") do |f|
    f.write(configuration.to_hash.to_json)
  end
end
