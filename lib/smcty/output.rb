def list_inventory(store)
  puts "-------------------------------------------------------------------"
  puts store.to_s
  puts "-------------------------------------------------------------------"
  puts "Current inventory:"
  puts ""
  store.inventory.each do |item|
    puts "\t#{item.name} (#{item.description}): #{store.stock(item)} items"
  end
end

def list_resources(resource_list)
  puts "-------------------------------------------------------------------"
  puts "Registered Resources:"
  puts ""
  resource_list.each do |r|
    puts "\t#{r.to_s}"
  end
end

def list_factories(factory_list)
  puts "-------------------------------------------------------------------"
  puts "Registered Factories:"
  puts ""
  factory_list.each do |f|
    puts "\t#{f.to_s}"
  end
end

def list_factory(factory)
  puts "-------------------------------------------------------------------"
  puts factory.to_s
  puts "-------------------------------------------------------------------"
  puts "Available resources:"
  puts ""
  factory.resources.each do |resource|
    puts "\t#{resource.to_s} (Time: #{natural_time(factory.production_time(resource))})"
  end
end

def list_configuration(configuration)
  puts "==================================================================="
  puts "Configuration created at: #{configuration.created_at}"
  puts "==================================================================="
  puts ""
  list_inventory(configuration.store)
  configuration.factories.each do |factory_name|
    puts ""
    outline_factory(configuration.factory(factory_name))
  end
end
