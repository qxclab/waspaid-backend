class UsersController < ApplicationController
  include Concerns::ResourceController

  def index
    render json: resource_class.all.map{ |x| {id: x.id, email: x.email } }
  end
end
