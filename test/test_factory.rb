require 'timecop'
require 'minitest/autorun'
require 'smcty/factory'

module Smcty
  describe Factory do
    before do
      @factory = Factory.new("test", 1)
    end

    it "has a capacity" do
      @factory.capacity.must_equal 1
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

    describe "production" do
      before do
        @resource_1 = Resource.new("name-1", "description-1")
        @resource_2 = Resource.new("name-2", "description-2")
        @resource_3 = Resource.new("name-3", "description-3")

        @resource_2.register_dependency(@resource_1, 2)

        @factory.register_resource(@resource_1, 60)
        @factory.register_resource(@resource_2, 0)

        @store = Store.new("store", 10)
        @store.put(@resource_1, 5)
        @store.put(@resource_2, 5)
      end

      it "has a free capacity" do
        @factory.free_capacity.must_equal 1
      end

      it "does not produce a not registered resource" do
        @factory.produce(@resource_3).must_be_nil
        @factory.free_capacity.must_equal @factory.capacity
      end

      it "produces a resource without dependencies if capacity is left" do
        production = @factory.produce(@resource_1)

        @factory.free_capacity.must_equal (@factory.capacity - 1)
        production.wont_be_nil
        production.resource.must_equal @resource_1
      end

      it "does not produce a resource without dependencies if no capacity is left" do
        @factory.produce(@resource_1)
        production = @factory.produce(@resource_1)

        production.must_be_nil
      end

      describe "with dependencies" do
        before do
          @allocation = @store.allocate(@resource_1, 2)
        end

        it "produces a resource if all dependencies are fullfilled and capacity is left" do
          production = @factory.produce(@resource_2, [@allocation])

          @factory.free_capacity.must_equal (@factory.capacity - 1)
          production.wont_be_nil
          production.resource.must_equal @resource_2
        end

        it "consumes provided allocations" do
          @factory.produce(@resource_2, [@allocation])

          @allocation.valid?.must_equal false
        end

        it "does not produce a resource if an allocation is invalid" do
          alloc_1 = @store.allocate(@resource_1, 1)
          alloc_2 = @store.allocate(@resource_1, 1)
          alloc_2.get
          production = @factory.produce(@resource_2, [alloc_1, alloc_2])

          production.must_be_nil
          alloc_1.valid?.must_equal true
        end

        it "does not produce a resource if all dependencies are fullfilled but no capacity is left" do
          @factory.produce(@resource_1)
          production = @factory.produce(@resource_1)

          production.must_be_nil
        end

        it "does not produce a resource if dependencies are not fullfilled" do
          alloc_1 = @store.allocate(@resource_1, 1)
          production = @factory.produce(@resource_2, [alloc_1])

          production.must_be_nil
          alloc_1.valid?.must_equal true
        end
      end

      describe "pick-up" do
        before do
          @production = @factory.produce(@resource_1)
        end

        it "allows to pick-up a finished production" do
          Timecop.freeze(Time.now + 70) do
            @factory.pick(@production)
            @factory.free_capacity.must_equal @factory.capacity
          end
        end

        it "does not allow to pick-up a not finished production" do
          @factory.pick(@production)

          @factory.free_capacity.must_equal 0
        end
      end

    end

  end
end
