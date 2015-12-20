def list_inventory(store)
  puts "-------------------------------------------------------------------"
  puts store.to_s
  puts "-------------------------------------------------------------------"
  puts "Current inventory:"
  puts ""
  store.inventory.each do |item|
    puts "\t#{item.name}: #{store.stock(item)} items"
  end
end

def outline_factory(factory)
  puts "-------------------------------------------------------------------"
  puts factory.to_s
  puts "-------------------------------------------------------------------"
  puts "Available resources:"
  puts ""
  factory.resources.each do |resource|
    puts "\t#{resource.to_s}"
  end
end

def outline_configuration(configuration)
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
