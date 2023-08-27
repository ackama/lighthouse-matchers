# frozen_string_literal: true

require 'rspec/retry'
require 'bundler/setup'
require 'lighthouse/matchers'
require 'lighthouse/matchers/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Show retry status in spec process. Otherwise tests just seem
  # slow for no reason
  config.verbose_retry = true

  # run retry only on integration tests
  config.around :each, type: :integration do |ex|
    # Retry once before failing. The retry count is inclusive
    ex.run_with_retry retry: ENV.fetch('RSPEC_RETRY', 3).to_i
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
