$:.unshift File.expand_path("../..", __FILE__)

require 'app'
require 'webmock'
require 'webmock/rspec'
require 'rack/test'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def api_response(data, include_root=false)
  resp = JSON.parse(data)
  resp = resp['data'] if !include_root
  resp
end

def repo_request(repo, path, params={})
  get(path, params.merge(:repo => repo))
end
