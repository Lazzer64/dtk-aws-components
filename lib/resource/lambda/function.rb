class Resource
  class Lambda
    class Function < self

      METADATA = {
        function_name: [:key, :create],
        runtime: [:create],
        handler: [:create],
        role: [:create],
        code: [:create]
      }

      private

      def create
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

      def delete
        @aws_client.delete_function(function_name: @function_name)
      end

      def update_code
        @aws_client.update_function_code(
          function_name: @desired_properties[:function_name],
          zip_file: File.read(@desired_properties[:code][:zip_file]),
          s3_bucket: @desired_properties[:code][:s3_bucket],
          s3_key: @desired_properties[:code][:s3_key],
          s3_object_version: @desired_properties[:code][:s3_object_version]
        )
      end

      def update_configuration
        @aws_client.update_function_configuration(
          function_name: @desired_properties[:function_name],
          runtime: @desired_properties[:runtime],
          handler: @desired_properties[:handler],
          role: @desired_properties[:role]
        )
      end

      def exists?
        begin
          @aws_client.get_function_configuration(function_name: @desired_properties[:function_name])
        rescue Aws::Lambda::Errors::ResourceNotFoundException
          return false
        end
        true
      end

      def populate_current_properties
        resp = @aws_client.get_function_configuration(function_name: @desired_properties[:function_name])
        @current_properties = {
          :function_name => resp.function_name,
          :function_arn => resp.function_arn,
          :runtime => resp.runtime,
          :role => resp.role,
          :handler => resp.handler,
          :code_size => resp.code_size,
          :description => resp.description,
          :timeout => resp.timeout,
          :memory_size => resp.memory_size,
          :last_modified => resp.last_modified,
          :code_sha_256 => resp.code_sha_256,
          :version => resp.version
        }
      end

      def process_diff(diff)
        if diff.key?(:runtime) || diff.key?(:role) || diff.key?(:handler) || diff.key?(:code)
          update_configuration
        end

        if diff.key?(:code) then update_code end
      end
    end
  end
end
