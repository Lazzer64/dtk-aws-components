class Resource
  class Kinesis
    class Stream < self

      METADATA = {
        stream_name: [:key, :create],
        shard_count: [:create],
        stream_arn: [],
        stream_status: [],
        shards: [],
        has_more_shards: [],
        retention_period_hours: [],
        enhanced_monitoring: []
      }

      private

      def create_resource
        begin
          @aws_client.create_stream(
            stream_name: @desired_properties[:stream_name],
            shard_count: @desired_properties[:shard_count]
          )
        end
      end

      def delete_resource
        resp = @aws_client.describe_stream(stream_name: @desired_properties[:stream_name])
        unless resp.stream_description.stream_status == 'DELETING'
          @aws_client.delete_stream(stream_name: @desired_properties[:stream_name])
        end
      end

      def process_diff(diff)
        # TODO
      end

      def exists?
        begin
          @aws_client.describe_stream(stream_name: @desired_properties[:stream_name])
        rescue Aws::Kinesis::Errors::ResourceNotFoundException
          return false
        end
        true
      end

      def properties?
        resp = @aws_client.describe_stream(stream_name: @desired_properties[:stream_name]).stream_description
        return Resource::Properties.new(self.class, resp.to_h)
      rescue Aws::Kinesis::Errors::ResourceNotFoundException
          return nil
      end
    end
  end
end
