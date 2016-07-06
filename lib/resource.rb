require 'aws-sdk'
require 'json'

class Resource
  require_relative 'resource/diff'
  require_relative 'resource/lambda'
  require_relative 'resource/kinesis'
  require_relative 'resource/properties'
  require_relative 'resource/exceptions'

  def initialize(desired_hash)
    @desired_properties = Properties.new(self.class, desired_hash)
  end

  def create
    raise MissingProperties if not @desired_properties.valid?(:create)
    raise ResourceAlreadyExists if exists?
    create_resource 
    output(properties?)
  end

  def delete
    raise MissingProperties if not @desired_properties.valid?(:key)
    delete_resource 
  end

  def modify
    raise MissingProperties if not @desired_properties.valid?(:key)

    @current_properties = properties?
    raise ResourceDoesNotExist if @current_properties == nil

    diff = get_diff(@current_properties, @desired_properties)
    process_diff(diff)

    output(properties?)
  end

  private

  def output(properties)
    File.new("output.json",  "w+").write(properties?.to_json)
  end

  def exists?
    raise MissingProperties if not @desired_properties.valid?(:key)
    properties? != nil
  end

  def keys(tag)
    return METADATA.keys if tag.nil?
    self.class::METADATA.keys.select { |key| self.class::METADATA[key].include?(tag) }
  end

  def create_resource
    raise Unimplemented
  end

  def delete_resource
    raise Unimplemented
  end

  def process_diff
    raise Unimplemented
  end

  def properties?
    raise Unimplemented
  end

  def get_diff(current, desired)
    diff = Diff.new

    @desired_properties.keys.each do |key|
      next unless current[key] != desired[key]
      diff[key] = desired[key]
    end

    diff
  end
end
