require 'microsoft-translator'
require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!(allow_localhost: true)
VCR.configure do |config|
  config.cassette_library_dir = "spec/support/recordings"
  config.hook_into :webmock
end
