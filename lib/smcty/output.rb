def list_inventory(store)
  puts "---------------------------------------------------------------------------------------"
  puts store.to_s
  puts "---------------------------------------------------------------------------------------"
  puts "Current inventory:"
  puts ""
  store.inventory.each do |item|
    puts "\t#{item.name}: #{store.available_stock(item)} items (allocated: #{store.allocated_stock(item)})"
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

def list_project(project)
  puts "-------------------------------------------------------------------"
  puts "Project #{project.name}"
  puts ""
  project.resources.each do |r|
    puts "\t#{r.name} - #{project.amount(r)}"
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
  puts ""
  puts "Running production"
  factory.productions.each do |production|
    line = "\t#{production.object_id} -> #{production.resource.name}"
    line += " / started at: #{production.start_time}"
    line += " / duration: #{production.duration}"
    line += " / delivery at: #{production.start_time + production.duration}"
    line + " / finished: #{production.finished?}"
    puts line
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
