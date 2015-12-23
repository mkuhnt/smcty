module Smcty
  class Factory
    attr_reader :name, :capacity, :productions

    def initialize(name, capacity)
      @name = name
      @capacity = capacity
      @resources = {}
      @production_times = {}
      @productions = []
    end

    def free_capacity
      capacity - @productions.size
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

    def produce(resource, allocations=[])
      unless free_capacity > 0
        raise "The factory has no capacity for further production"
      end

      unless Factory.check_preconditions(resource, allocations)
        raise "The preconditions for this production aren't met"
      end

      time = @production_times[resource]
      unless time
        raise "The resource #{resource.name} is not registered with this factory"
      end

      allocations.each{ |a| a.get }
      production = Production.new(resource, time)
      @productions << production
      production
    end

    def pick(production)
      if production && production.finished?
        @productions.delete(production)
      end
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

    def self.check_preconditions(resource, allocations)
      allocated_resources = {}
      allocations.each do |a|
        if a.valid?
          depot = allocated_resources[a.resource] || {amount: 0}
          depot[:amount] += a.amount
          allocated_resources[a.resource] = depot
        end
      end

      resource.dependent_resources.each do |dr|
        required_amount = resource.dependent_resource_amount(dr)
        depot = allocated_resources[dr]
        if depot && depot[:amount] >= required_amount
          depot[:amount] -= required_amount
        else
          return false
        end
      end
      return true
    end

  end
end
