require 'spec_helper'

describe Resource::IAM::Role do

  client = Aws::IAM::Client.new(region: 'us-west-2')
  config = JSON.parse(File.read('./spec/fixtures/iam/role/config.json'))
  config2 = {
    region: config['region'],
    role_name: config['role_name'], 
    policies: [ 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
                'arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole' ]
  }

  def clean
    client = Aws::IAM::Client.new(region: 'us-west-2')
    config = JSON.parse(File.read('./spec/fixtures/iam/role/config.json'))
    begin
      policies = client.list_attached_role_policies(role_name: config['role_name']).attached_policies
      policies.each do |policy|
        client.detach_role_policy(role_name: config['role_name'], policy_arn: policy.policy_arn)
      end
      client.delete_role(role_name: config['role_name'])
    rescue Aws::IAM::Errors::NoSuchEntity
    end
  end

  before(:all) do
    clean
  end

  after(:each) do
    clean
  end

  describe '#create' do
      it 'creates the role' do
        expect{ 
          Resource::IAM::Role.new(config).create
          client.delete_role(role_name: config['role_name'])
        }.not_to raise_error
      end
  end
  describe '#modify' do
      it 'attaches a policy' do
        Resource::IAM::Role.new(config).create
        Resource::IAM::Role.new(config2).modify
        expect(client.list_attached_role_policies(role_name: config['role_name']).attached_policies.length > 0).to be true
      end
      # it 'changes the policy' do
      #   expect(false).to be true
      # end
      # it 'removes policies' do
      #   expect(false).to be true
      # end
  end
  describe '#delete' do
    it 'deletes the role' do
      expect{
        Resource::IAM::Role.new(config).create
        Resource::IAM::Role.new(config).delete
      }.not_to raise_error
    end
    context 'when policies are attached' do
      it 'detaches and deletes role' do
        expect{
          Resource::IAM::Role.new(config).create
          Resource::IAM::Role.new(config2).modify
          Resource::IAM::Role.new(config2).delete
        }.not_to raise_error
      end
    end
  end
end
