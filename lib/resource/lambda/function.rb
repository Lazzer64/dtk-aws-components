class Resource
  class Lambda
    class Function < self
      METADATA = {
        function_name: [:key, :create],
        runtime: [:create, :update_config],
        handler: [:create, :update_config],
        role: [:create, :update_config],
        code: [:create, :update_code],
        function_arn: [],
        code_size: [],
        description: [:update_config],
        timeout: [:update_config],
        memory_size: [:update_config],
        last_modified: [],
        code_sha_256: [],
        version: [],
        vpc_config: [:update_config]
      }.freeze

      private

      def create_resource
        @aws_client.create_function(
          function_name: @desired_properties[:function_name],
          runtime: @desired_properties[:runtime],
          handler: @desired_properties[:handler],
          role: @desired_properties[:role],
          code: {
            zip_file: File.read(@desired_properties[:code][:zip_file]),
            s3_bucket: @desired_properties[:code][:s3_bucket],
            s3_key: @desired_properties[:code][:s3_key],
            s3_object_version: @desired_properties[:code][:s3_object_version]
          }
        )
      end

      def delete_resource
        @aws_client.delete_function(function_name: @function_name)
      end

      def properties?
        resp = @aws_client.get_function_configuration(function_name: @desired_properties[:function_name])
        return Resource::Properties.new(self.class, resp.to_h)
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        return nil
      end

      def process_diff(diff)
        diff.each do |key, val|
          if keys(:update_config).include?(key)
            @aws_client.update_function_configuration(
              :function_name => @desired_properties[:function_name],
              key => val
            )
          end

          if keys(:update_code).include?(key)

            props = val.merge(function_name: @desired_properties[:function_name])
            props[:zip_file] = File.read(props[:zip_file]) if props.key?(:zip_file)

            @aws_client.update_function_code(props)
          end
          next
        end
      end
    end
  end
end
