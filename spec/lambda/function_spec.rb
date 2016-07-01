require 'spec_helper'
require_relative '../../resource'

describe Resource::Lambda::Function do

  client = Aws::Lambda::Client.new(region: 'us-west-2')

  config = {
    "region" => "us-west-2",
    "function_name" => "aTestFunction",
    "runtime" => "nodejs4.3",
    "role" => "arn:aws:iam::518021689748:role/lambda_basic_execution",
    "handler" => "index.handler",
    "code" => {
      "zip_file" => "./spec/fixtures/lambda/example.zip"
    }
  }
  config2 = {
    "region" => "us-west-2",
    "function_name" => "aTestFunction",
    "runtime" => "nodejs4.3",
    "role" => "arn:aws:iam::518021689748:role/lambda_basic_execution",
    "handler" => "server.handler",
    "code" => {
      "zip_file" => "./spec/fixtures/lambda/example2.zip"
    }
  }

  # Remove function if it exists already
  before(:all) do
    begin
      client.get_function(function_name: config['function_name'])
      client.delete_function(function_name: config['function_name'])
    rescue Aws::Lambda::Errors::ResourceNotFoundException
    end
  end

  describe ".converge" do
    context "When current_properties.json is missing and the function HAS NOT been created" do
      it "creates a lambda function from desired_properties.json" do

        Resource::Lambda::Function.new(config).converge
        expect(client.get_function(function_name: config['function_name'])).not_to eq(Aws::Lambda::Errors::ResourceNotFoundException)

      end
    end

    context "When current_properties.json is missing and the function HAS been created" do
      it "does nothing" do

        Resource::Lambda::Function.new(config).converge
        expect(client.get_function(function_name: config['function_name'])).not_to eq(Aws::Lambda::Errors::ResourceConflictException)

      end
    end

    context "When current_properties and desired_properties are given" do
      it "changes the configuration to match desired_properties" do

        Resource::Lambda::Function.new(config2, {current_hash: config}).converge
        resp = client.get_function(function_name: config['function_name'])
        expect(resp.configuration.handler).to eq('server.handler')

      end
    end
  end

  after(:all) do
    client.delete_function(function_name: config['function_name'])
  end
end
