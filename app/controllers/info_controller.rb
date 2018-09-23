class InfoController < ApplicationController

  def index
    render json: {
        api_version: '0.2.0'
    }, status: :ok
  end
end
