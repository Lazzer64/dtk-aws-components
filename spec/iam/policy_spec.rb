require 'spec_helper'

describe Resource::IAM::Policy do

  client = Aws::IAM::Client.new(region: 'us-west-2')

  config = JSON.parse(File.read('./spec/fixtures/iam/config.json'))
  config2 = JSON.parse(File.read('./spec/fixtures/iam/config2.json'))

  describe '#create' do
    it 'creates a policy' do
      expect{
        Resource::IAM::Policy.new(config).create
        arn = JSON.parse(File.read('output.json'))['arn']
        client.delete_policy(policy_arn: arn)
      }.not_to raise_error
    end
  end

  describe '#modify' do
    it 'updates the policy' do
      expect{
        Resource::IAM::Policy.new(config).create
        arn = JSON.parse(File.read('output.json'))['arn']

        policy = Resource::IAM::Policy.new(config.merge!(arn: arn))
        policy.modify
        policy.delete
      }.not_to raise_error
    end
  end
end
