class Resource
  class Properties < ::Hash
    def initialize(resource_class, props_hash)
      @resource_class = resource_class
      self.merge!(props_hash)
      raise "Invalid props hash #{props_hash} for resource '#{resource_class}'" unless valid?
    end

    private 

    def valid?
      # TODO
      true
    end

    def metadata
      @resource_class.metadata
    end

  end
end
