module Smcty
  class Allocation
    attr_reader :resource, :amount
    
    def initialize(resource, amount)
      @resource = resource
      @amount = amount
    end
  end
end
