require 'smcty/allocation'
require 'set'

module Smcty
  class Store
    attr_reader :name, :capacity

    def initialize(name, capacity)
      @name = name
      @capacity = capacity
      @storage = {}
      @allocations = Set.new
    end

    def free_capacity
      @capacity - total_available_stock - total_allocated_stock
    end

    def total_available_stock
      result = 0
      @storage.values.each do |value|
        result += value
      end
      result
    end

    def total_allocated_stock
      result = 0
      @allocations.each do |alloc|
        result += alloc.amount
      end
      result
    end

    def available_stock(resource)
      @storage[resource] || 0
    end

    def allocated_stock(resource)
      result = 0
      @allocations.each do |alloc|
        result += alloc.amount if resource == alloc.resource
      end
      result
    end

    def total_stock(resource)
      available_stock(resource) + allocated_stock(resource)
    end

    def put(resource, _amount=1)
      # at least one item of the resource
      amount = [1, _amount].max

      unless free_capacity >= amount
        raise "The store is full - Cannot put #{amount} items of #{resource.name}"
      end

      in_stock = available_stock(resource)
      @storage[resource] = in_stock + amount
      amount
    end

    def allocate(resource, _amount)
      # at least one item of the resource
      amount = [1, _amount].max

      in_stock = available_stock(resource)
      unless in_stock >= amount
        raise "#{in_stock} is not enough of #{resource.name} to allocate #{amount} items"
      end

      @storage[resource] = in_stock - amount
      allocation = Allocation.new(self, resource, amount)
      @allocations.add(allocation)
      allocation
    end

    def get(allocation)
      @allocations.delete(allocation)
    end

    def free(allocation)
      put(allocation.resource, allocation.amount)
      @allocations.delete(allocation)
    end

    def valid?(allocation)
      @allocations.include?(allocation)
    end

    def inventory
      @storage.keys
    end

    def to_s
      "Store #{@name} has a total capacity of #{@capacity} whereas the free capacity is #{free_capacity}"
    end

    def to_hash
      {
        "name" => @name,
        "capacity" => @capacity,
        "stock" => @storage.keys.map{|k| {"name" => k.name, "amount" => total_stock(k)}}
      }
    end

    private

    def enforce(lower, amount, upper)
      [[lower, amount].max, upper].min
    end

  end
end
