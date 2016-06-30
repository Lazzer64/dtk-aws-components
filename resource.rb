require 'aws-sdk'
require 'json'

class Resource
  require_relative 'resource/kinesis'
  require_relative 'resource/lambda'
  require_relative 'resource/diff'

  def initialize
    @current_properties = nil

    if File.exist?('./desired_properties.json')
      json = File.read('./desired_properties.json')
      @desired_properties = JSON.parse(json)
    else
      raise 'Missing desired_properties.json'
    end
  end

  def converge
    populate_current_properties
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
    if File.exist?('./current_properties.json')
      json = File.read('./current_properties.json')
      @current_properties = JSON.parse(json)
    end
  end

  def ordered_keys
    @desired_properties.keys
  end

  def get_diff(curr, desire)
    diff = Resource::Diff.new

    ordered_keys.each do |key|
      next unless curr[key] != desire[key]
      diff[key] = desire[key]
    end

    diff
  end
end

obj = Resource::Lambda::Function.new
obj.converge
