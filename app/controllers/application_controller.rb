class ApplicationController < ActionController::API

  rescue_from CanCan::AccessDenied do |exception|
    render json: {
        errors: [
            {
                status: '401',
                title: 'Unauthorized'
            }
        ]
    }, status: :unauthorized
  end

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
