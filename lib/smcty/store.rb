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
      @capacity - total_stock - allocated_stock
    end


    def put(resource, _amount=1)
      # at least one but not more than the free capacity
      amount = enforce(1, _amount, free_capacity)

      in_stock = stock(resource)
      @storage[resource] = in_stock + amount
      amount
    end

    def get(allocation)
      @allocations.delete(allocation)
    end

    def stock(resource)
      @storage[resource] || 0
    end

    def total_stock
      result = 0
      @storage.values.each do |value|
        result += value
      end
      result
    end

    def allocated_stock
      result = 0
      @allocations.each do |alloc|
        result += alloc.amount
      end
      result
    end

    def allocate(resource, _amount)
      amount = pop(resource, _amount)
      if amount > 0
        allocation = Allocation.new(resource, amount)
        @allocations.add(allocation)
        allocation
      else
        nil
      end
    end

    def free(allocation)
      put(allocation.resource, allocation.amount)
      @allocations.delete(allocation)
    end

    def inventory
      @storage.keys
    end

    def to_s
      "Store '#{@name}' has a capacity of #{@capacity} and a total stock of #{total_stock}"
    end

    def to_hash
      {
        "name" => @name,
        "capacity" => @capacity,
        "stock" => @storage.keys.map{|k| {"name" => k.name, "amount" => @storage[k]}}
      }
    end

    private

    def pop(resource, _amount=1)
      in_stock = stock(resource)
      # at least one but not more than in the stock
      amount = enforce(1, _amount, in_stock)

      @storage[resource] = in_stock - amount
      amount
    end

    def enforce(lower, amount, upper)
      [[lower, amount].max, upper].min
    end

  end
end
