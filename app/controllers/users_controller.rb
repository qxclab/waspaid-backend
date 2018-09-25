class UsersController < ApplicationController
  include Concerns::ResourceController

  def index
    render json: resource_class.all.map { |x| x.as_json(only: [:id, :email]) }
  end
end
