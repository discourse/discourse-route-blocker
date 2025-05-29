# frozen_string_literal: true

class RouteBlockerMiddleware
  STATIC_PATHS = %w[assets/ images/ uploads/ stylesheets/ service-worker/]

  ALLOWED_PATHS = %w[
    srv/status
    u/admin-login
    users/admin-login
    session/email-login
    session/csrf
    logs/report_js_error
    manifest.webmanifest
    admin
    login
    signup
  ]

  def initialize(app, _options = {})
    @app = app
  end

  def call(env)
    if SiteSetting.route_blocker_enabled && is_blocked?(env)
      RouteBlockerController.action("blocked").call(env)
    else
      @app.call(env)
    end
  end

  private

  def is_admin?(env)
    CurrentUser.lookup_from_env(env)&.admin?
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end

  def is_api_request?(env)
    env["HTTP_API_KEY"].present? || env["HTTP_API_USERNAME"].present?
  end

  def absolute_path(path)
    File.join("/", GlobalSetting.relative_url_root.to_s, path)
  end

  def starts_with_any?(string, prefixes)
    string.starts_with?(*prefixes.map { |prefix| absolute_path(prefix) })
  end

  def matches_any?(string, paths)
    paths.any? { |path| string == absolute_path(path) }
  end

  def is_static?(path)
    path.present? && starts_with_any?(path, STATIC_PATHS)
  end

  def is_allowed?(path)
    return false if path.blank?

    matches_any?(path, ALLOWED_PATHS)
  end

  def is_blocked?(env)
    return false if !SiteSetting.route_blocker_block_admins && is_admin?(env)
    return false if is_static?(env["PATH_INFO"])
    return false if is_allowed?(env["PATH_INFO"])
    return false if is_api_request?(env)

    path = env["PATH_INFO"].to_s
    blocked_routes = SiteSetting.route_blocker_blocked_routes.split("|")

    # Check if the path matches any blocked route (including .json and .html versions)
    blocked =
      blocked_routes.any? do |route|
        base_path = "/#{route}"
        match = path == base_path || path == "#{base_path}.json" || path == "#{base_path}.html"
        match
      end

    blocked
  end
end
