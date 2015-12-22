module Smcty
  class Factory
    attr_reader :name, :capacity

    def initialize(name, capacity)
      @name = name
      @capacity = capacity
      @resources = {}
      @production_times = {}
      @productions = []
    end

    def register_resource(resource, production_time)
      @production_times[resource] = production_time
      @resources[resource.name] = resource
    end

    def resources
      @production_times.keys
    end

    def production_time(resource)
      @production_times[resource]
    end

    def resource_by_name(name)
      @resources[name]
    end

    def to_s
      "Factory '#{@name}' with capacity of #{@capacity} is responsible for #{@resources.keys.join(", ")}"
    end

    def to_hash
      {
        "name" => @name,
        "capacity" => @capacity,
        "resources" => @resources.values.map{|r| r.to_hash(@production_times[r])}
      }
    end

  end
end
