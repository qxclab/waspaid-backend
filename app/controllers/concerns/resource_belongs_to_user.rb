module Concerns
  module ResourceBelongsToUser
    extend ActiveSupport::Concern

    included do
      before_action :set_user, only: :create

      private

      def set_user
        @resource.user = current_user
      end

      def permitted_attributes
        @permitted_attributes ||= attributes - %w( id created_at updated_at user_id )
      end
    end
  end
end
