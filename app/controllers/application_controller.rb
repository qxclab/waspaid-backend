class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def render_resource(resource, _opt = nil)
    if resource.errors.empty?
      render json: resource.as_json(_opt)
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
        errors: [
            {
                status: '400',
                title: 'Bad Request',
                detail: resource.errors
            }
        ]
    }, status: :bad_request
  end
end
