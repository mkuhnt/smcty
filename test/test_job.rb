require 'minitest/autorun'

require 'smcty/job'
require 'smcty/project'

module Smcty
  describe Job do
    before do
      @project = Project.new("project-1")
      @resource = Resource.new("name", "description")
    end

    it "is flaged to be a new job initially" do
      job = Job.new(@resource, @project)

      job.new?.must_equal true
    end


  end
end
