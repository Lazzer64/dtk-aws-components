class Resource
  class Lambda < self
    require_relative 'lambda/function'

    def initialize(*args)
      super
      @aws_client = Aws::Lambda::Client.new(region: @desired_properties['region'])
    end
  end
end
