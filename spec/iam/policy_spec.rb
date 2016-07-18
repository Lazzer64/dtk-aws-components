require 'spec_helper'

describe Resource::IAM::Policy do

  client = Aws::IAM::Client.new(region: 'us-west-2')

  config = JSON.parse(File.read('./spec/fixtures/iam/config.json'))
  config2 = JSON.parse(File.read('./spec/fixtures/iam/config2.json'))

  after(:each) do
    props = JSON.parse(File.read('output.json'))
    Resource::IAM::Policy.new(
      arn: props['arn'],
      region: config['region']
    ).delete
  end

  describe '#create' do
    it 'creates a policy' do
      expect{
        Resource::IAM::Policy.new(config).create
      }.not_to raise_error
    end
  end

  describe '#modify' do
    it 'updates the policy' do
      arn = Resource::IAM::Policy.new(config).create[:arn]
      expect{
        policy = Resource::IAM::Policy.new(config2.merge!(arn: arn))
        policy.modify
      }.not_to raise_error
    end
  end
end
