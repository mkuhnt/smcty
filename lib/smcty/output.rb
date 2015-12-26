#
# (1) Parallel Production
#
#     line 1 -> minerals -> 2m 30s left to finish at 11:51
#     line 2 -> wood     -> 1m 15s left to finish at 11:55
#     line 3 -> empty
#
# (2) Sequential Production
#
#     current -> veg     -> 25m 10s left to finish at 12:15
#     -------    -------
#     queued  -> flour   -> to start at 12:15 for 45m
#     queued  -> veg     -> to start at 13:00 for 30m
#
def show_production(factory)
  if factory.sequential
    show_sequential_production(factory)
  else
    show_parallel_production(factory)
  end
end

def show_parallel_production(factory)
  puts "Factory '#{factory.name}' (parallel processing)"
  puts "Capacity: #{factory.capacity}"
  puts ""
  factory.productions.each_with_index do |production, index|
    name = normalize_length(production.resource.name, 15)
    time_left = natural_time((production.end_time - Time.now).to_i)
    end_time = production.end_time.strftime("%H:%M:%S")
    puts "line #{"%02d" % index} -> #{name} -> #{time_left} to finish at #{end_time}"
  end
end

def show_sequential_production(factory)
  "todo"
end

def normalize_length(text, length)
  result = text
  if text.length < length
    (length - text.length).times do
      result += " "
    end
  end
  result
end

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
  puts "sequential: #{factory.sequential}"
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
