require 'minitest/autorun'
require 'smcty/configuration'
require 'smcty/factory'
require 'smcty/resource'
require 'smcty/store'

module Smcty
  describe Configuration do
    before do
      @factory_1 = Factory.new("factory-1", 1)
      @factory_2 = Factory.new("factory-2", 1)

      @r1 = Resource.new("r1", "resource 1")
      @r2 = Resource.new("r2", "resource 2")
      @factory_1.register_resource(@r1, 60)
      @factory_1.register_resource(@r2, 60)

      @r3 = Resource.new("r3", "resource 3")
      @r4 = Resource.new("r4", "resource 4")
      @factory_2.register_resource(@r3, 60)
      @factory_2.register_resource(@r4, 60)

      @store = Store.new("store", 10)
      @configuration = Configuration.new(@store)
      @configuration.register_factory(@factory_1)
      @configuration.register_factory(@factory_2)
    end

    it "lists all the names of all registered factories" do
      @configuration.factories.must_equal [@factory_1.name, @factory_2.name]
    end

    it "lists a resources registered in factories" do
      @configuration.resources.must_equal [@r1, @r2, @r3, @r4]
    end

    it "returns the factory for a resource" do
      @configuration.factory_for(@r2).must_equal @factory_1
    end

    it "returns the resource by its name" do
      @configuration.resource_by_name("r3").must_equal @r3
    end

  end
end
