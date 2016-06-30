class Resource
  class Kinesis
    class Stream < self
      def create
        begin
          @aws_client.create_stream(
            stream_name: desired_properties['stream_name'],
            shard_count: desired_properties['shard_count']
          )
        rescue => e
          raise e
        end
        describe
      end

      def delete
        @aws_client.delete_stream(
          stream_name: @stream_name
        )
      end

      def process_diff(diff)
      end
    end
  end
end
