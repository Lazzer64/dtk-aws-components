require 'spec_helper'

describe Resource::Kinesis::Stream do
  client = Aws::Kinesis::Client.new(region: 'us-west-2')

  config = JSON.parse(File.read('./spec/fixtures/kinesis/config.json'))

  # Remove stream if it exists already
  before(:all) do
    begin
      client.delete_stream(stream_name: config['stream_name'])
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
    end
  end

  after(:each) do
    begin
      client.delete_stream(stream_name: config['stream_name'])
    rescue Aws::Kinesis::Errors::ResourceNotFoundException
    end
  end

  describe '#create' do
    context 'Resource DOES NOT exist' do
      it 'creates the resource' do
        Resource::Kinesis::Stream.new(config).create
        expect { client.describe_stream(stream_name: config['stream_name']) }.not_to raise_error
      end
    end
    context 'Resource DOES exist' do
      it 'Throws an error' do
        Resource::Kinesis::Stream.new(config)
        expect { Resource::Kinesis::Stream.new(config).create }.to raise_error Resource::ResourceAlreadyExists
      end
    end
  end
end
