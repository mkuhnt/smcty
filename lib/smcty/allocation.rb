module Smcty
  class Allocation
    attr_reader :store, :resource, :amount

    def initialize(store, resource, amount)
      @store = store
      @resource = resource
      @amount = amount
    end

    def valid?
      @store.valid?(self)
    end

    def get
      @store.get(self)
    end
  end
end
