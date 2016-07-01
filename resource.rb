require 'aws-sdk'
require 'json'

class Resource
  require_relative 'resource/diff'
  require_relative 'resource/lambda'
  require_relative 'resource/kinesis'
  require_relative 'resource/properties'

  # Opts can have keys
  # :current_hash
  def initialize(desired_hash, opts = {})
    @desired_properties = Properties.new(self.class, desired_hash)
    @current_properties = opts[:current_hash] && Properties.new(self.class, opts[:current_hash])
  end

  def converge
    if @current_properties.nil?
      create
    else
      diff = get_diff(@current_properties, @desired_properties)
      process_diff(diff)
    end
  end

  private

  def create
    raise 'Unimplemented'
  end

  def delete
    raise 'Unimplemented'
  end

  def process_diff
    raise 'Unimplemented'
  end

  def populate_current_properties
    # TODO 
  end

  def get_diff(current, desired)
    diff = Resource::Diff.new

    @desired_properties.keys.each do |key|
      next unless current[key] != desired[key]
      diff[key] = desired[key]
    end

    diff
  end
end

# config = JSON.parse(File.read('./spec/fixtures/lambda/current_properties.json'))
# configNew = JSON.parse(File.read('./spec/fixtures/lambda/desired_properties.json'))

# Resource::Lambda::Function.new(config).converge
# Resource::Lambda::Function.new(configNew, {current_hash: config}).converge
