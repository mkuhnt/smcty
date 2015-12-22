require 'minitest/autorun'
require 'smcty'

module Smcty
  describe Store do
    before do
      @store = Store.new("test", 10)
      @resource_1 = Resource.new("name-1", "description-1")
      @resource_2 = Resource.new("name-2", "description-2")
    end

    describe "allocation" do

      it "can allocate available stock" do
        @store.put(@resource_1, 5)
        result = @store.allocate(@resource_1, 3)

        result.must_be_kind_of(Allocation)
        result.amount.must_equal 3
        @store.free_capacity.must_equal 5
        @store.stock(@resource_1).must_equal 2
      end

      it "cannot allocate more than available stock" do
        @store.put(@resource_1, 5)
        result = @store.allocate(@resource_1, 6)

        result.must_be_kind_of(Allocation)
        result.amount.must_equal 5
        @store.free_capacity.must_equal 5
        @store.stock(@resource_1).must_equal 0
      end

      it "cannot allocate not available stock" do
        result = @store.allocate(@resource_1, 1)

        result.must_be_nil
      end

      it "can free allocated stock" do
        @store.put(@resource_1, 5)
        allocation = @store.allocate(@resource_1, 3)
        @store.free(allocation)

        @store.free_capacity.must_equal 5
        @store.stock(@resource_1).must_equal 5
      end

      it "can get allocated stock" do
        @store.put(@resource_1, 5)
        allocation = @store.allocate(@resource_1, 3)
        @store.get(allocation)

        @store.free_capacity.must_equal 8
        @store.stock(@resource_1).must_equal 2
      end
    end

    describe "capacity" do
      # capacity() -> total capacity of the store
      #
      it "has a total capacity" do
        @store.capacity.must_equal 10
      end

      # free_capacity() -> available capacity that can be used.
      #
      it "has a free capacity" do
        @store.put(@resource_1, 5)
        @store.free_capacity.must_equal 5
      end
    end

    describe "storage" do
      it "can store a number of items per resource" do
        result = @store.put(@resource_1, 2)

        result.must_equal 2
        @store.stock(@resource_1).must_equal 2
      end

      it "cannot store more items than the free capacity" do
        @store.put(@resource_1, 6)
        result = @store.put(@resource_2, 10)

        result.must_equal 4
        @store.stock(@resource_2).must_equal 4
      end

      it "has a total stock of all resources" do
        @store.put(@resource_1, 4)
        @store.put(@resource_2, 3)

        @store.total_stock.must_equal 7
      end

      it "has an inventory" do
        @store.put(@resource_1, 4)
        @store.put(@resource_2, 3)

        @store.inventory.must_equal [@resource_1, @resource_2]
      end
    end
  end
end
