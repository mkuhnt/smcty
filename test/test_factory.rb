require 'minitest/autorun'
require 'smcty/factory'

module Smcty
  describe Factory do
    before do
      @factory = Factory.new("test", 10)
    end

    it "has a capacity" do
      @factory.capacity.must_equal 10
    end

    describe "resource management" do
      before do
        @resource_1 = Resource.new("name-1", "description-1")
        @resource_2 = Resource.new("name-2", "description-2")
        @factory.register_resource(@resource_1, 60)
      end

      it "can register a resource for production" do
        @factory.resources.must_equal [@resource_1]
      end

      it "stores the production time for a resource" do
        @factory.production_time(@resource_1).must_equal 60
      end

      it "finds a registered resource by its name" do
        @factory.resource_by_name(@resource_1.name).must_equal @resource_1
      end

    end

  end
end
