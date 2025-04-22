# frozen_string_literal: true

# name: discourse-route-blocker
# about: A plugin to block specific routes in Discourse
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-route-blocker
# required_version: 2.7.0

enabled_site_setting :route_blocker_enabled

module ::RouteBlocker
  PLUGIN_NAME = "discourse-route-blocker"
end

require_relative "lib/route_blocker/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
