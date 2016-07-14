class Resource
  class IAM
    class Role < self
      METADATA = {
        role_name: [:key, :create],
        assume_role_policy_document: [:create],
        policies: [:update_policy]
      }.freeze

      private 

      def create_resource
        @aws_client.create_role(role_name: @desired_properties[:role_name], assume_role_policy_document: @desired_properties[:assume_role_policy_document])
      end

      def delete_resource
        detach_polocies
        @aws_client.delete_role(role_name: @desired_properties[:role_name])
      end

      def process_diff(diff)
        diff.each do |key, val|
          if keys(:update_policy).include?(key)
            detach_polocies
            val.each do |policy_arn|
              @aws_client.attach_role_policy(role_name: @desired_properties[:role_name], policy_arn: policy_arn)
            end
          end
        end
      end

      def properties?
        resp = @aws_client.get_role(role_name: @desired_properties[:role_name])
        props = Resource::Properties.new(self.class, resp.role.to_h)
        props[:region] = @desired_properties[:region]
        return props
      rescue Aws::IAM::Errors::NoSuchEntity
        nil
      end

      def detach_polocies
        policies = @aws_client.list_attached_role_policies(role_name: @desired_properties[:role_name]).attached_policies
        policies.each do |policy|
          @aws_client.detach_role_policy(role_name: @desired_properties[:role_name], policy_arn: policy.policy_arn)
        end
      end

    end
  end
end
