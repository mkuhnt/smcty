require 'smcty/configurator'
require 'smcty/output'
require 'smcty/helpers'

module Smcty
  class Console

    # Initialize the console with the input stream (e.g. $stdin)
    # and a path to smcty configuration file.
    def initialize(input_stream, config_path)
      @in = input_stream
      @configurator = Configurator.new(config_path)
      @configuraton = @configurator.configuration
    end

    def prompt!
      run = true
      while run
        "-> ".display
        run = dispatch(@in.gets.chomp)
      end
    end

    # Commands
    #
    #   quit
    #
    #   store                   -> list the inventory of the store
    #   store put #item #amount
    #   store get :item #amount
    #
    #   factory list            -> list the registered factories
    #   factory #name           -> list the resources and the production of the named factory
    #
    #   resources               -> list all managed resources
    #
    #   project add #label [#resource:#amount]+
    #   project #label
    #
    #   produce #resource
    #
    #   next
    #
    def dispatch(input)
      continue = true
      commands = input.split(" ")
      case commands[0].downcase
      when "store"
        continue = process_store(commands[1..-1])
      when "factory"
        continue = process_factory(commands[1..-1])
      when "quit"
        continue = process_quit
      when "resources"
        continue = process_resources
      when "project"
        continue = process_projects(commands[1..-1])
      else
        puts "unknown command: #{input}"
      end
      return continue
    end

    def process_projects(commands)
      # project object {label, [{resource, amount}]}
      # -> scheduling.register_project(...)
      true
    end

    def process_resources
      list_resources(@configuraton.resources)
      true
    end

    def process_quit
      puts "Storing configuraton back to file and exit."
      @configurator.save
      false
    end

    def process_store(commands)
      if commands.size == 0
        list_inventory(@configuraton.store)
      elsif commands.size == 3
        resource = @configuraton.resource_by_name(commands[1])
        amount = commands[2].to_i
        if resource && amount > 0
          case commands[0].downcase
          when "get"
            puts "get #{commands[2]} units of #{commands[1]} from store"
            result = @configuraton.store.get(resource, amount)
            puts "got #{result} items resulting in stock of #{@configuraton.store.stock(resource)}"
          when "put"
            puts "put #{commands[2]} units of #{commands[1]} to store"
            result = @configuraton.store.put(resource, amount)
            puts "new stock is: #{@configuraton.store.stock(resource)}"
          else
            puts "operator on store was not recognized"
          end
        else
          puts "resource '#{commands[1]}' or amount '#{commands[2]}' not valid"
        end
      else
        puts "command not recognized"
      end
      true
    end

    def process_factory(commands)
      if commands.size == 0
        list_factories(@configuraton.factories)
      else
        factory = @configuraton.factory(commands[0])
        if factory
          list_factory(factory)
        else
          puts "The factory '#{commands[0]}' is not registered"
        end
      end
      true
    end

  end
end
