module Smcty
  class Configuration
    attr_reader :created_at, :store, :scheduler

    def initialize(store)
      @created_at = Time.new
      @store = store
      @factories = {}
      @scheduler = Scheduling.new(self)
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

    def resources
      result = []
      @factories.values.each do |f|
        result += f.resources
      end
      result
    end

    def factory_for(resource)
      @factories.values.each do |factory|
        found = factory.resource_by_name(resource.name)
        return factory if found
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
        "store" => @store.to_hash,
        "factories" => @factories.values.map{|f| f.to_hash},
        "scheduling" => @scheduler.to_hash
      }
    end

  end
end
