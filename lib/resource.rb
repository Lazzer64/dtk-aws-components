require 'aws-sdk'
require 'json'

class Resource
  require_relative 'resource/iam'
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
    raise ResourceAlreadyExists if @desired_properties.valid?(:key) && exists?
    create_resource 
    output(properties?)
    properties?
  end

  def delete
    raise MissingProperties if not @desired_properties.valid?(:key)
    @current_properties = properties?
    delete_resource 
  end

  def modify
    raise MissingProperties if not @desired_properties.valid?(:key)
    @current_properties = properties?
    raise ResourceDoesNotExist if @current_properties == nil
    @current_properties[:region] = @desired_properties[:region]

    diff = get_diff(@current_properties, @desired_properties)
    process_diff(diff)

    output(properties?)
  end

  private

  def get_diff(current, desired)
    diff = Diff.new
    @desired_properties.keys.each do |key|
      next unless current[key] != desired[key]
      diff[key] = desired[key]
    end
    format_diff!(diff)
    diff
  end

  def output(properties)
    json = properties.to_json
    File.open('output.json', 'w') { |file| file.write(json) }
    json
  end

  def exists?
    raise MissingProperties if not @desired_properties.valid?(:key)
    properties? != nil
  end

  def keys(tag)
    return METADATA.keys if tag.nil?
    self.class::METADATA.keys.select { |key| self.class::METADATA[key].include?(tag) }
  end

  def properties?
    return nil if raw_properties.nil?
    parse_properties(raw_properties)
  end

  def parse_properties(raw_props)
    Resource::Properties.new(self.class, raw_props)
  end

  def format_diff!(diff)
    diff
  end

  def raw_properties
    raise Unimplemented
  end

  def create_resource
    raise Unimplemented
  end

  def delete_resource
    raise Unimplemented
  end

  def process_diff(diff)
    raise Unimplemented
  end
end
