require 'spec_helper'

describe Resource::Kinesis::Stream do

  client = Aws::Kinesis::Client.new(region: 'us-west-2')

  config = {
    "stream_name"=> "aTestStreamName",
    "shard_count"=> 1,
    "region"=> "us-west-2"
  }

  # Remove stream if it exists already
  before(:all) do
    begin
      client.delete_stream(stream_name: config['stream_name'])
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
    end
  end

  describe ".converge" do
    context "When current_properties.json is missing and the stream HAS NOT been created" do
      it "creates a kinesis stream from desired_properties" do

        Resource::Kinesis::Stream.new(config).converge
        expect(client.describe_stream(stream_name: config['stream_name'])).not_to eq(Aws::Kinesis::Errors::ResourceNotFoundException)
      end
    end

    context "When current_properties is missing and the function HAS been created" do
      it "does nothing" do

        Resource::Kinesis::Stream.new(config).converge
        expect(client.describe_stream(stream_name: config['stream_name'])).not_to eq(Aws::Lambda::Errors::ResourceConflictException)
      end
    end

    after(:all) do
      client.delete_stream(stream_name: config['stream_name'])
    end
  end
end
