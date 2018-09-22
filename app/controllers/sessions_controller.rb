class SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render_resource(resource)
  end

  def respond_to_on_destroy
    render json: {
        success: :true
    }, status: :ok
  end
end
