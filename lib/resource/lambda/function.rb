require 'digest'

class Resource
  class Lambda
    class Function < self
      METADATA = {
        function_name: [:key, :create],
        runtime: [:create, :update_config],
        handler: [:create, :update_config],
        role: [:create, :update_config],
        code: [:create, :update_code],
        description: [:update_config],
        timeout: [:update_config],
        memory_size: [:update_config],
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
        @aws_client.delete_function(function_name: @desired_properties[:function_name])
      end

      def raw_properties
        @aws_client.get_function_configuration(function_name: @desired_properties[:function_name])
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        nil
      end

      def parse_properties(raw_props)
        Resource::Properties.new(self.class, raw_props.to_h)
      end

      def update_code(code)
        # TODO code from s3
        unless code[:zip_file].nil?
          zip = File.read(code[:zip_file])
          @aws_client.update_function_code(
            function_name: @desired_properties[:function_name],
            zip_file: zip
          )
        end
      end

      def same_code?(code, current)
        # TODO code from s3
        return false if code.nil?
        unless code[:zip_file].nil?
          zip = File.read(code[:zip_file])
          sha = Digest::SHA256.base64digest(zip) 
          sha == current[:code_sha_256]
        end
      end

      def format_diff!(diff)
        diff.delete(:code) if same_code?(diff[:code], properties?) 
        diff
      end

      def process_diff(diff)
        diff.each do |key, val|
          if keys(:update_config).include?(key)
            @aws_client.update_function_configuration(
              :function_name => @desired_properties[:function_name],
              key => val
            )
          end
          update_code(diff[:code]) if keys(:update_code).include?(key)
          next
        end
      end
    end
  end
end
