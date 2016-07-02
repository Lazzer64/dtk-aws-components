require 'aws-sdk'
require 'json'

class Resource
  require_relative 'resource/diff'
  require_relative 'resource/lambda'
  require_relative 'resource/kinesis'
  require_relative 'resource/properties'
  require_relative 'resource/exceptions'

  # Opts can have keys
  # :current_hash
  def initialize(desired_hash, opts = {})
    @desired_properties = Properties.new(self.class, desired_hash)
    @current_properties = opts[:current_hash] && Properties.new(self.class, opts[:current_hash])
  end

  def converge
    if exists?
      if @current_properties.nil? then populate_current_properties end
      diff = get_diff(@current_properties, @desired_properties)
      process_diff(diff)
    else
      create
    end
  end

  private

  def create
    raise Resource::Unimplemented
  end

  def delete
    raise Resource::Unimplemented
  end

  def process_diff
    raise Resource::Unimplemented
  end

  def populate_current_properties
    raise Resource::Unimplemented
  end

  def exists?
    raise Resource::Unimplemented
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
