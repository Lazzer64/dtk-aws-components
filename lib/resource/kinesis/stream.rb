class Resource
  class Kinesis
    class Stream < self

      METADATA = {
        stream_name: [:required],
        shard_count: []
      }

      private

      def create
        begin
          @aws_client.create_stream(
            stream_name: @desired_properties[:stream_name],
            shard_count: @desired_properties[:shard_count]
          )
        rescue => e
          raise e
        end
      end

      def delete
        @aws_client.delete_stream(stream_name: @desired_properties[:stream_name])
      end

      def process_diff(diff)
        
      end

      def exists?
        begin
          @aws_client.describe_stream(stream_name: @desired_properties[:stream_name])
        rescue Aws::Kinesis::Errors::ResourceNotFoundException
          return false
        end
        true
      end

      def populate_current_properties

        resp = @aws_client.describe_stream(stream_name: @desired_properties[:stream_name])

        @current_properties = {
          :stream_name => resp.stream_description.stream_name,
          :stream_arn => resp.stream_description.stream_arn,
          :stream_status => resp.stream_description.stream_status,
          :shards => resp.stream_description.shards,
          :has_more_shards => resp.stream_description.has_more_shards,
          :retention_period_hours => resp.stream_description.retention_period_hours,
          :enhanced_monitoring => resp.stream_description.enhanced_monitoring
        }

      end
    end
  end
end
