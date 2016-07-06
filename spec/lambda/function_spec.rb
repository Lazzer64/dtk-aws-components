require 'spec_helper'

describe Resource::Lambda::Function do
  client = Aws::Lambda::Client.new(region: 'us-west-2')

  config = JSON.parse(File.read('./spec/fixtures/lambda/config1.json'))
  config2 = JSON.parse(File.read('./spec/fixtures/lambda/config2.json'))

  config_bad = {
    "region" => "us-west-2",
    "runtime" => "nodejs4.3"
  }

  # Remove function if it exists already
  before(:all) do
    begin
      client.delete_function(function_name: config['function_name'])
    rescue Aws::Lambda::Errors::ResourceNotFoundException
    end
  end

  after(:each) do
    begin
      client.delete_function(function_name: config['function_name'])
    rescue Aws::Lambda::Errors::ResourceNotFoundException
    end
  end

  describe '#create' do
    context "Resource DOES NOT exist" do
      it "Create the resource" do
        Resource::Lambda::Function.new(config).create
        expect { client.get_function(function_name: config['function_name']) }.not_to raise_error
      end
    end

    context "Resource DOES exist" do
      it "Throws an error" do
        Resource::Lambda::Function.new(config).create 
        expect { Resource::Lambda::Function.new(config).create }.to raise_error Resource::ResourceAlreadyExists
      end
    end
  end

  describe "#modify" do
    context "All keys are present and the function DOES exist" do
      it "changes the function configuration to match desired properties" do
        Resource::Lambda::Function.new(config).create
        Resource::Lambda::Function.new(config2).modify
        resp = client.get_function(function_name: config['function_name'])
        expect(resp.configuration.description).to eq(config2['description'])
        expect(resp.configuration.handler).to eq(config2['handler'])
      end
    end

    context "All keys are present and the function DOES exist" do
      it "changes the function code to match desired properties" do
        Resource::Lambda::Function.new(config).create
        code_sha1 = client.get_function(function_name: config['function_name']).configuration.code_sha_256

        config_code_update = {function_name: config['function_name'], region: 'us-west-2', code: {zip_file: './spec/fixtures/lambda/example2.zip'}}
        Resource::Lambda::Function.new(config_code_update).modify

        code_sha2 = Aws::Lambda::Client.new(region: 'us-west-2').get_function(function_name: config['function_name']).configuration.code_sha_256

        expect(code_sha2).not_to eq code_sha1
      end
    end

    context "All keys are present and the function DOES NOT exist" do
      it "Throw an error" do
        expect { Resource::Lambda::Function.new(config2).modify }.to raise_error Resource::ResourceDoesNotExist
      end
    end
  end
end
