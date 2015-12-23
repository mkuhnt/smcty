require 'minitest/autorun'
require 'smcty/allocation'

module Smcty
  describe Allocation do
    before do
      @store = Store.new("test", 10)
      @resource_1 = Resource.new("name", "description")
      @store.put(@resource_1, 6)
    end

    it "is associated with a store" do
      allocation = @store.allocate(@resource_1, 3)

      allocation.store.must_equal @store
    end

    it "knows if it is still valid" do
      allocation = @store.allocate(@resource_1, 3)

      allocation.valid?.must_equal true

      @store.get(allocation)

      allocation.valid?.must_equal false
    end

    it "can get the allocated resources" do
      allocation = @store.allocate(@resource_1, 3)
      allocation.get

      allocation.valid?.must_equal false
      @store.available_stock(@resource_1).must_equal 3
      @store.allocated_stock(@resource_1).must_equal 0

    end
  end
end
