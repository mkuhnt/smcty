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
      @other_resource = Resource.new("other", "description")
      @job = Job.new(@resource)
      @other_job = Job.new(@other_resource)
      @store = Store.new("test", 20)
      @store.put(@resource, 5)
      @store.put(@other_resource, 10)
    end

    describe "status" do

      it "is 'new' if it has no allocation, production or dependent job" do
        @job.new?.must_equal true
      end

      it "is 'in production' if a production is assigned but is not ready" do
        @job.produce(Production.new(@resource, 60))
        @job.in_production?.must_equal true
      end

      it "is 'ready' if a production is assigned but it is ready" do
        @job.produce(Production.new(@resource, 60))

        Timecop.freeze(Time.now + 70) do
          @job.ready?.must_equal true
        end
      end

      it "is 'allocated' if a valid allocation is assigned" do
        @job.allocate(@store.allocate(@resource, 2))
        @job.allocated?.must_equal true
      end

      it "has 'dependencies' if any other job is associated" do
        @job.add_dependent(@other_job)

        @job.dependencies?.must_equal true
      end

      it "has allocated dependencies if dependent jobs are allocated" do
        @other_job.allocate(@store.allocate(@other_resource, 2))
        @job.add_dependent(@other_job)

        @job.allocated_dependencies?.must_equal true
      end

    end
  end
end
