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

    def produce(resource)
      check_resource(resource)
      if @capacity = @productions.size
        raise "Factory '#{@name}' is currently blocked with productions."
      end

      production = Production.new(resource)
      @productions << production

      production
    end

    def ship(resource)
      check_resource(resource)

      result = nil
      @productions.each_with_index do |idx, production|
        if production.resource == resource && production.finished?
          result = production
          @productions.delete_at(idx)
        end
      end
      result
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

    private

    def check_resource(resource)
      unless (@production_times[resource])
        raise "Factory '#{@name}' cannot produce '#{resource.name}'"
      end
    end
  end
end
