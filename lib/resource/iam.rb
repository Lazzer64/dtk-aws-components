class Resource
  class IAM < self
    require_relative 'iam/policy'

    def initialize(*args)
      super(*args)
      @aws_client = Aws::IAM::Client.new(region: @desired_properties[:region])
    end
  end
end
