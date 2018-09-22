module Concerns
  module ResourceBelongsToUser
    extend ActiveSupport::Concern

    included do
      before_action :set_user, only: %i[create update]

      private

      def set_user
        @resource.user = current_user
      end
    end
  end
end
