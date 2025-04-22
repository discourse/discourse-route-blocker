# frozen_string_literal: true

class RouteBlockerController < ApplicationController
  def blocked
    render json: { error: "Access denied" }, status: :forbidden
  end
end
