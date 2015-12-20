class Requirement
  attr_reader :resource, :amount

  def initialize(resource, amount)
    @resource = resource
    @amount = amount > 0 ? amount : 0
  end
end

class Project
  attr_reader :created_at, :description, :requirements

  def initialize(configuration, description, requirements)
    @created_at = Time.now
    @description = description
    @config = configuration
    @steps = []
    requirements.each do |requirement|
      @steps << Step.new(self, resource)
    end
  end

  def finished?
    result = false
    @steps.each do |step|
      result = step.finished?
      break if result
    end
    result
  end

  def factory_for(resource)
    @config.factory_for(resource)
  end

end

class Step
  attr_reader :resource, :production

  def initialize(project, resource)
    @project = project
    @resource = resource
    @production = nil
  end

  def start_production
    @production = @project.factory_for(@resource).produce(@resource)
  end

  def running?
    @production != nil && !@production.finished?
  end

  def finished?
    @production != nil && @production.finished?
  end

end
