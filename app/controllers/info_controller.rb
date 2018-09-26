class InfoController < ApplicationController

  def index
    render json: {
        api_version: '0.2.1'
    }, status: :ok
  end
end
