class Store
  attr_reader :name, :capacity

  def initialize(name, capacity)
    @name = name
    @capacity = capacity
    @storage = {}
  end

  def put(resource, amount=1)
    in_stock = look_up(resource)
    @storage[resource] = in_stock + enforce_amount(amount)
  end

  def get(resource, amount=1)
    norm_amount = enforce_amount(amount)
    in_stock = look_up(resource)
    if in_stock > norm_amount
      @storage[resource] = in_stock - norm_amount
      norm_amount
    else
      0
    end
  end

  def stock(resource)
    look_up(resource)
  end

  def inventory
    @storage.keys
  end

  def total_stock
    result = 0
    @storage.values.each do |value|
      result += value
    end
    result
  end

  def to_s
    "Store '#{@name}' has a capacity of #{@capacity} and a total stock of #{total_stock}"
  end

  def to_hash
    {
      "name": @name,
      "capacity": @capacity,
      "stock": @storage.keys.map{|k| {"name": k, "amount": @storage[k]}}
    }
  end

  private

  def enforce_amount(amount)
    amount > 0 ? amount : 0
  end

  def look_up(resource)
    @storage[resource] || 0
  end

end

class Resource
  attr_reader :name

  def initialize(name)
    @name = name
    @dependencies = {}
  end

  def register_dependency(resource, amount)
    @dependencies[resource] = amount
  end

  def dependent_resources
    @dependencies.keys
  end

  def dependent_resource_amount(resource)
    @dependencies[resource]
  end

  def to_s
    "Resource '#{@name}' with these dependencies: #{dependency_list}"
  end

  def to_hash(time)
    {
      "name": @name,
      "time": time,
      "deps": @dependencies.keys.map{|r| {"name": r.name, "amount": @dependencies[r]}}
    }
  end

  private

  def dependency_list
    items = []
    @dependencies.keys.each do |resource|
      items << "#{resource.name}: #{@dependencies[resource]}"
    end
    items.join(", ")
  end
end

class Factory
  attr_reader :name, :capacity

  def initialize(name, capacity)
    @name = name
    @capacity = capacity
    @resources = {}
    @production_times = {}
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
      "name": @name,
      "capacity": @capacity,
      "resources": @resources.values.map{|r| r.to_hash(@production_times[r])}
    }
  end

end
