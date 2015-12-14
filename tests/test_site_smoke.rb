ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'

class TestSiteSmoke < Minitest::Test
  def test_site_smoke
    browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
    browser.get '/'
    assert browser.last_response.ok?
  end
end
