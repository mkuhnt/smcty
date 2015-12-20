require_relative 'calculator'

if ARGV.size == 0
  puts "please specifiy a start configuration."
  exit 1
end

def dispatch(input, config)
  continue = true
  commands = input.split(" ")
  case commands[0].downcase
  when "store"
    continue = process_store(commands[1..-1], config)
  when "factory"
    continue = process_factory(commands[1..-1], config)
  when "quit"
    continue = process_quit(config)
  when "resources"
    continue = process_resources(config)
  else
    puts "unknown command: #{input}"
  end
  return continue
end

# Commands
#
#   quit
#
#   store list              -> list the inventory of the store
#   store put item amount
#   store get item amount
#
#   factory list            -> list the registered factories
#   factory name            -> list the resources of the named factory
#
#   resources               -> list all managed resources

def process_resources(config)
  list_resources(config.resources)
  true
end

def process_quit(config)
  puts "Storing configuraton back to file and exit."
  write_configuration(config, ARGV[0])
  false
end

def process_store(commands, config)
  if commands.size == 0
    list_inventory(config.store)
  elsif commands.size == 3
    resource = config.resource_by_name(commands[1])
    amount = commands[2].to_i

    case commands[0].downcase
    when "get"
      puts "get #{commands[2]} units of #{commands[1]} from store"
      puts config.store.get(resource, amount)
    when "put"
      puts "put #{commands[2]} units of #{commands[1]} to store"
      puts config.store.put(resource, amount)
    else
      puts "operator on store was not recognized"
    end
  else
    puts "command not recognized"
  end
  true
end

def process_factory(commands, config)
  if commands.size == 0
    list_factories(config.factories)
  else
    factory = config.factory(commands[0])
    if factory
      list_factory(factory)
    else
      puts "The factory '#{commands[0]}' is not registered"
    end
  end
  true
end

def command_prompt!(config)
  run = true
  while run
    "-> ".display
    run = dispatch($stdin.gets.chomp, config)
  end
end

configuration = read_configuration(ARGV[0])
puts "Starting Simcity Production Assistent"
puts "  loaded configuration from #{ARGV[0]}"


command_prompt!(configuration)
