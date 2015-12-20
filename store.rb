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
      "stock": @storage.keys.map{|k| {"name": k.name, "amount": @storage[k]}}
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
