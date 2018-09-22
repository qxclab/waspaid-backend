module Concerns
  module ResourceController
    extend ActiveSupport::Concern

    included do
      load_and_authorize_resource

      before_action :attributes, :permitted_attributes
      before_action :collection, only: :index
      before_action :build_resource, only: :create
      before_action :resource, only: %i[show update destroy]

      def index
        render json: resource_class.all.select{|x| can?(:manage, x) }.map(&:as_json)
      end

      def show
        render_resource(@resource)
      end

      def create
        @resource.update(resource_params)
        render_resource(@resource)
      end

      def update
        @resource.update(resource_params)
        render_resource(@resource)
      end

      def destroy
        @resource.destroy
        render json: {
            success: :true
        }, status: :ok
      end

      private

      def attributes
        @attributes ||= resource_class.attribute_names
      end

      def collection_name
        @collection_name ||= controller_name
      end

      def resource_name
        @resource_name ||= collection_name.singularize
      end

      def resource_class
        @resource_class ||= resource_name.classify.constantize
      end

      def permitted_attributes
        @permitted_attributes ||= attributes - %w( id created_at updated_at)
      end

      def resource_params
        params.require(resource_name.to_sym).permit(permitted_attributes)
      end

      def association_chain
        resource_class.all
      end

      def collection
        @collection ||= association_chain
      end

      def resource
        @resource ||= resource_class.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          @resource = nil
          render json: {
              errors: [
                  {
                      status: '404',
                      title: 'Record Not Found'
                  }
              ]
          }, status: :not_found
        end
    end

    def build_resource
      @resource ||= resource_class.new
    end
  end
end
