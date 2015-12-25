module Smcty
  class Production
    attr_reader :start_time, :duration, :resource

    def initialize(resource, duration, start_time=nil)
      @start_time = start_time ? Time.at(start_time) : Time.now
      @duration = duration
      @resource = resource
    end

    def finished?
      end_time <= Time.now
    end

    def end_time
      @start_time + duration
    end

    def to_s
      "Production of #{resource.name} starts #{@start_time} takes #{natural_time(@duration)} (Finished: #{finished?})"
    end

    def to_hash
      {
        "start_time" => @start_time.to_i,
        "duration" => @duration,
        "resource" => @resource.name
      }
    end
  end
end
