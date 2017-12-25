require 'bundler/setup'
require 'todoable'
require 'webmock/rspec'
require 'rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    stub_unauthenticated_requests
  end
end

def stub_unauthenticated_requests
  stub_request(:post, /authenticate/)
    .to_return(status: 401)
end

def stub_authentication(user, password)
  stub_request(:post, /authenticate/)
    .with(basic_auth: [user, password])
    .to_return(status: 200, body: {token: 'my_token'}.to_json)
end
