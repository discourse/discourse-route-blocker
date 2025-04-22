# frozen_string_literal: true

class RouteBlockerController < ApplicationController
  def blocked
    render json: { error: "Not Found" }, status: :not_found
  end
end
