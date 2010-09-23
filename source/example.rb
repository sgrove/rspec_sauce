require 'rubygems'
require 'json'
require 'selenium/client'
require 'selenium/rspec/spec_helper'
require 'net/http'
require 'yaml'

browsers = YAML.load_file("browsers_full.yml")
ondemand = YAML.load_file("ondemand.yml")

browsers[:browsers].each do |browser|
  puts "Creating test for #{browser[:name]} #{browser[:version]} on #{browser[:os]} now"

  describe "Google Search" do
    attr_reader :selenium_driver
    alias :page :selenium_driver

    before(:all) do
      @selenium_driver = Selenium::Client::Driver.new \
      :host => "saucelabs.com",
      :port => 4444,
      :browser => 
        {
        "username" => ondemand[:username],
        "access-key" => ondemand[:api_key],
        "os" => browser[:os],
        "browser" => browser[:name],
        "browser-version" => browser[:version],
        "job-name" => 
        "Sauce Labs RSpec Example - #{browser[:name]} #{browser[:version]} on #{browser[:os]}"
      }.to_json,           
      :url => "http://www.saucelabs.com",
      :timeout_in_second => 90
    end

    before(:each) do
      selenium_driver.start_new_browser_session
    end

    # The system capture need to happen BEFORE closing the Selenium session
    append_after(:each) do
      Selenium::RSpec::SeleniumTestReportFormatter.capture_system_state(@selenium_driver, self)
      @selenium_driver.close_current_browser_session
    end

    it "can find Selenium" do
      page.open "/"
      page.title.should eql("Sauce Labs - Selenium-based Downloads, Hosting and Support")
    end

  end
end
