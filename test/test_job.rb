require 'timecop'
require 'minitest/autorun'
require 'smcty/job'
require 'smcty/resource'
require 'smcty/store'
require 'smcty/production'

module Smcty
  describe Job do
    before do
      @resource = Resource.new("name", "description")
      @job = Job.new(@resource)
      @store = Store.new("test", 10)
      @store.put(@resource, 5)
    end

    describe "status" do

      it "has the status 'new' initially" do
        @job.status.must_equal :new
      end

      it "has the status 'in production' if a production and no allocation is assigned" do
        @job.produce(Production.new(@resource, 60))
        @job.status.must_equal :in_production
      end

      it "has the status 'allocated' if a valid allocation is assigned" do
        @job.allocate(@store.allocate(@resource, 2))
        @job.status.must_equal :allocated
      end

      it "has the status 'ready' if the assinged production is finished" do
        @job.produce(Production.new(@resource, 60))

        Timecop.freeze(Time.now + 70) do
          @job.status.must_equal :ready
        end
      end

    end
  end
end
