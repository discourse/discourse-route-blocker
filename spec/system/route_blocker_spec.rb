# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Route Blocker", type: :system do
  before do
    SiteSetting.route_blocker_enabled = true
    SiteSetting.route_blocker_blocked_routes = "about|site/statistics|faq"
  end

  it "blocks access to the about page" do
    visit "/about"
    expect(page).to have_current_path("/404")
  end

  it "blocks access to the about.json endpoint" do
    visit "/about.json"
    expect(page).to have_content('{"error":"Not Found"}')
  end

  it "blocks access to the site statistics page" do
    visit "/site/statistics"
    expect(page).to have_css(".page-not-found")
  end

  it "blocks access to the site statistics.json endpoint" do
    visit "/site/statistics.json"
    expect(page).to have_content('{"error":"Not Found"}')
  end

  it "blocks access to the faq page" do
    visit "/faq"
    expect(page).to have_css(".still-loading")
  end
end
