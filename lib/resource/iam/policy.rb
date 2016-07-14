class Resource
  class IAM
    class Policy < self
      METADATA = {
        arn: [:key],
        policy_name: [:create],
        Action: [:create, :update_policy],
        Effect: [:create, :update_policy],
        Resource: [:create, :update_policy]
      }.freeze

      private 

      def create_resource
        build_policy_document
        resp = @aws_client.create_policy(
          policy_name: @desired_properties[:policy_name],
          path: @desired_properties[:path],
          policy_document: @desired_properties[:policy_document],
          description: @desired_properties[:description]
        )
        @desired_properties[:arn] = resp.policy.arn
      end

      def delete_resource
        # Must:
        # TODO Detach from policy from all users, groups, and roles
        # Delete all versions of the policy
        detach_from_all
        delete_versions
        @aws_client.delete_policy(policy_arn: @desired_properties[:arn])
      end

      def process_diff(diff)
        build_policy_document
        # Can only have 5 versions at once
        delete_versions
        @aws_client.list_policy_versions(
          policy_arn: @current_properties[:arn]
        )

        resp = @aws_client.create_policy_version(
          policy_arn: @current_properties[:arn],
          set_as_default: true,
          policy_document: @desired_properties[:policy_document]
        )
      end

      def properties?
        resp = @aws_client.get_policy(policy_arn: @desired_properties[:arn])
        props = Resource::Properties.new(self.class, resp.policy.to_h)
        props[:region] = @desired_properties[:region]
        return props
      rescue Aws::IAM::Errors::ResourceNotFoundException
        nil
      end

      def build_policy_document
        @desired_properties[:policy_document] = {
          "Version" => "2012-10-17",
          "Statement" => [
            {
              'Action' => @desired_properties[:Action],
              'Effect' => @desired_properties[:Effect],
              'Resource' => @desired_properties[:Resource]
            }
          ]
        }.to_json
      end

      def delete_versions
        @aws_client.list_policy_versions(policy_arn: @current_properties[:arn]).versions.each do |version| 
          next if version.is_default_version
          @aws_client.delete_policy_version(
            policy_arn: @current_properties[:arn],
            version_id: version.version_id
          )
        end
      end

      def detach_from_all
        # TODO
      end
    end
  end
end

