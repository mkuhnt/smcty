require 'smcty/configurator'
require 'smcty/output'
require 'smcty/helpers'
require 'smcty/production'
require 'smcty/project'
require 'smcty/scheduling'

module Smcty
  class Console

    # Initialize the console with the input stream (e.g. $stdin)
    # and a path to smcty configuration file.
    def initialize(input_stream, config_path)
      @in = input_stream
      @configurator = Configurator.new(config_path)
      @configuration = @configurator.configuration
      @productions = {}

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
    #
    #   factory                 -> list the registered factories
    #   factory #name           -> list the resources and the production of the named factory
    #
    #   resources               -> list all managed resources
    #
    #   project add #label [#resource:#amount]+
    #   project #label
    #
    #   produce #resource
    #
    #   pick #production-number
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
      when "produce"
        continue = process_production(commands[1..-1])
      when "pick"
        continue = process_pick(commands[1..-1])
      when "next"
        continue = process_next
      when "scheduling"
        continue = process_scheduling
      else
        puts "unknown command: #{input}"
      end
      return continue
    end

    def process_scheduling
      @configuration.scheduler.print_job_lists
      true
    end

    def process_next
      puts "DO > #{@configuration.scheduler.next}"
      true
    end

    def process_projects(commands)
      if commands.size == 1
        puts "print the project"
      elsif commands.size > 2
        unless commands[0] == "add"
          puts "unknow command #{commands[0]} for project is not known"
          return true
        end
        project = Project.new(commands[1])
        requirements = commands[2..-1]
        requirements.each do |r|
          items = r.split(":")
          r_name = items[0]
          amount = items[1].to_i
          resource = @configuration.resource_by_name(r_name)
          unless resource
            puts "the resource #{resource_name} is not known"
            return true
          end
          project.add_requirement(resource, amount)
        end
        @configuration.scheduler.plan_project(project)
        puts "planned the project"
      else
        puts "not enough parameters for project command"
      end
      true
    end

    def process_pick(commands)
      if commands.size != 1
        puts "please pass the number of production to pick"
      else
        number = commands[0].to_i
        production = @productions[number]
        unless production
          puts "the production number #{commands[0]} is not known"
          return true
        end
        unless production.finished?
          puts "the production is not finished yet"
          return true
        end
        if @configuration.store.free_capacity > 0
          factory = @configuration.factory_for(production.resource)
          factory.pick(production)
          @productions.delete(number)
          @configuration.store.put(production.resource, 1)
          puts "the item was stored"
        else
          puts "no storage left"
        end
      end
      true
    end

    def process_production(commands)
      if commands.size != 1
        puts "please name the resource to produce"
      else
        resource_name = commands[0]
        resource = @configuration.resource_by_name(resource_name)
        unless resource
          puts "the resource #{resource_name} is not known"
          return true
        end
        factory = @configuration.factory_for(resource)
        allocations = []
        resource.dependent_resources.each do |r|
          allocation = @configuration.store.allocate(r, resource.dependent_resource_amount(r))
          unless allocation
            puts "Not enough of #{r.name} to produce #{resource_name}"
            return true
          end
          allocations << allocation
        end
        production = factory.produce(resource, allocations)
        @productions[production.object_id] = production
        puts "Now producing: #{production.object_id} in factory: #{factory.name}"
      end
      true
    end

    def process_resources
      list_resources(@configuration.resources)
      true
    end

    def process_quit
      puts "Storing configuration back to file and exit."
      @configurator.save
      false
    end

    def process_store(commands)
      if commands.size == 0
        list_inventory(@configuration.store)
      elsif commands.size == 3
        resource = @configuration.resource_by_name(commands[1])
        amount = commands[2].to_i
        if resource && amount > 0
          case commands[0].downcase
          when "put"
            puts "put #{commands[2]} units of #{commands[1]} to store"
            result = @configuration.store.put(resource, amount)
            puts "new stock is: #{@configuration.store.stock(resource)}"
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
        list_factories(@configuration.factories)
      else
        factory = @configuration.factory(commands[0])
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
