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
  ]

  ABOUT_PATHS = %w[
    about
    about.json
  ]

  STATISTICS_PATHS = %w[
    site/statistics
    site/statistics.json
  ]

  BLOCKED_PATHS = %w[
    # Add other blocked paths here
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

    path = env["PATH_INFO"].to_s

    # Check if path is in ABOUT_PATHS and about blocking is enabled
    if SiteSetting.route_blocker_block_about
      about_match = ABOUT_PATHS.any? { |p| path == "/#{p}" || path == "/#{p}.json" }
      return true if about_match
    end

    # Check if path is in STATISTICS_PATHS and statistics blocking is enabled
    if SiteSetting.route_blocker_block_statistics
      stats_match = STATISTICS_PATHS.any? { |p| path == "/#{p}" || path == "/#{p}.json" }
      return true if stats_match
    end

    # Check if path is in BLOCKED_PATHS (always blocked)
    BLOCKED_PATHS.any? { |p| path == "/#{p}" || path == "/#{p}.json" }
  end
end
