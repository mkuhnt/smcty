require 'timecop'
require 'minitest/autorun'
require 'smcty/production'

module Smcty
  describe Production do
    before do
      @resource = Resource.new("test", "description")
      @production = Production.new(@resource, 60)
    end

    it "has a production duration" do
      @production.duration.must_equal 60
    end

    it "has a start time" do
      @production.start_time.wont_be_nil
    end

    it "knows when the production has finished" do
      production = Production.new(@resource, 60)
      production.finished?.must_equal false

      Timecop.freeze(Time.now + 70) do
        production.finished?.must_equal true
      end
    end
  end
end
