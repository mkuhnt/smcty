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
    @storage.keys.sort
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
    @dependencies.keys.sort
  end

  def dependent_resource_amount(resource)
    @dependencies[resource]
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
    @production_times.keys.sort
  end

  def production_time(resource)
    @production_times[resource]
  end

  def resource_by_name(name)
    @resources[name]
  end

end
