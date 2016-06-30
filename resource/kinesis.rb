class Resource
  class Kinesis < self
    require_relative 'kinesis/stream'

    def initialize
      @aws_client = Aws::Kinesis::Client.new(region: @desired_properties['region'])
    end
  end
end
