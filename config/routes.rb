# frozen_string_literal: true

RouteBlocker::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::RouteBlocker::Engine, at: "route-blocker" }
