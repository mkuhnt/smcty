require 'timecop'
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
      @r3.register_dependency(@r4, 1)

      @factory = Factory.new("factory", 10)
      @factory.register_resource(@r1, 60)
      @factory.register_resource(@r2, 60)
      @factory.register_resource(@r3, 60)
      @factory.register_resource(@r4, 60)

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
      scheduler.plan_project(@project)
      action = scheduler.next

      action.must_equal "finish #{@project.name}"
    end

    it "triggers 'produce resource' if all dependent resources are set and one direct is missing" do
      @store.put(@r1, 2)
      @store.put(@r2, 2)
      @store.put(@r4, 1)
      scheduler = Scheduling.new(@configuration)
      scheduler.plan_project(@project)
      action = scheduler.next

      action.must_equal "produce #{@r2.name}"
    end

    it "tiggers 'produce resource' if a dependent resource is missing" do
      @store.put(@r1, 2)
      scheduler = Scheduling.new(@configuration)
      scheduler.plan_project(@project)
      action = scheduler.next

      action.must_equal "produce #{@r4.name}"
    end

    it "triggers 'pick resource' if the missing resource is ready" do
      @store.put(@r1, 2)
      @store.put(@r2, 2)
      @store.put(@r4, 1)
      scheduler = Scheduling.new(@configuration)
      scheduler.plan_project(@project)

      scheduler.next # -> produce r2 (takes 60 sec)

      Timecop.freeze(Time.now + 80) do
        scheduler.next.must_equal "pick #{@r2.name}"
      end
    end

    it "triggers 'wait' if no jobs are ready" do
      @store.put(@r1, 2)
      @store.put(@r2, 2)
      @store.put(@r4, 1)
      scheduler = Scheduling.new(@configuration)
      scheduler.plan_project(@project)
      scheduler.next # -> produce r2 (takes 60 sec)

      scheduler.next.must_equal "wait"
    end

    it "tirggers 'wait' if a production cannot be launched due to capacity limits" do
      @store.put(@r1, 2)
      @store.put(@r4, 1)
      # put load on the factory
      @factory.capacity.times do
        @factory.produce(@r4)
      end
      # factory has no capacity left
      scheduler = Scheduling.new(@configuration)
      scheduler.plan_project(@project)

      scheduler.next.must_equal "wait" # -> although produce r2 is next up
    end

  end
end
