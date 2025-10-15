# frozen_string_literal: true

RSpec.describe "Route Blocker", type: :system do
  before do
    SiteSetting.route_blocker_enabled = true
    SiteSetting.route_blocker_blocked_routes = "about|site/statistics|faq"
  end

  def expect_json_error
    expect(page).to have_content(
      "{\"errors\":[\"The requested URL or resource could not be found.\"],\"error_type\":\"not_found\"}",
    )
  end

  def expect_page_not_found
    expect(page).to have_css(".page-not-found")
  end

  it "blocks access to the about page" do
    visit "/about"

    expect_page_not_found
  end

  it "blocks access to the about.json endpoint" do
    visit "/about.json"

    expect_json_error
  end

  it "blocks access to the site statistics page" do
    visit "/site/statistics"

    expect_page_not_found
  end

  it "blocks access to the site statistics.json endpoint" do
    visit "/site/statistics.json"

    expect_json_error
  end

  it "blocks access to the faq page" do
    visit "/faq"

    expect_page_not_found
  end
end
