ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'

class TestSiteSmoke < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_site_can_run
    get '/'
    assert last_response.ok?
  end
end
