require 'minitest/autorun'
require 'smcty/scheduling'
require 'smcty/resource'
require 'smcty/factory'
require 'smcty/project'
require 'smcty/store'

module Smcty
  describe Scheduling do
    # Structure of the test configuration
    #
    # Resources
    #   r1 -> r2:1, r3:2
    #   t2 -> t4:1
    #
    # Project
    #   Build with 2x r1 and 3x r2
    #
    before do
      @r1 = Resource.new("r1", "resource 1")
      @r2 = Resource.new("r2", "resource 2")
      @r3 = Resource.new("r3", "resource 3")
      @r4 = Resource.new("r4", "resource 4")

      @r1.register_dependency(@r2, 1)
      @r1.register_dependency(@r3, 2)
      @r2.register_dependency(@r4, 1)

      @factory = Factory.new("factory", 10)
      @factory.register_resource(@r1, 5)
      @factory.register_resource(@r2, 5)
      @factory.register_resource(@r3, 5)
      @factory.register_resource(@r4, 5)

      @project = Project.new("project")
      @project.add_requirement(@r1, 2)
      @project.add_requirement(@r2, 3)

      @store = Store.new("store", 100)

      @configuration = Configuration.new(@store)
      @configuration.register_factory(@factory)
    end

    it "triggers 'finish project' if all requirements are fullfilled" do
      @store.put(@r1, 2)
      @store.put(@r2, 3)

      scheduler = Scheduling.new(@configuration)
    end

    it "triggers 'produce resource' if all dependent resources are set and one direct is missing" do

    end

    it "tiggers 'produce resource' if a dependent resource is missing" do

    end

    it "triggers 'pick resource' if the missing resource is ready" do

    end

    it "triggers 'wait' if no jobs are ready" do

    end

    it "tirggers 'wait' if a production cannot be launched due to capacity limits" do
      
    end

  end
end
