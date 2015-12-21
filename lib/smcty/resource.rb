class Resource
  attr_reader :name, :description

  def initialize(name, description)
    @name = name
    @description = description
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
    "Resource '#{@name}' (#{@description}) with these dependencies: #{dependency_list}"
  end

  def to_hash(time)
    {
      "name" => @name,
      "description" => @description,
      "time" => time,
      "deps" => @dependencies.keys.map{|r| {"name" => r.name, "amount" => @dependencies[r]}}
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
