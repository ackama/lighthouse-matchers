# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'json'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, score: nil|
  match do |target|
    score ||= Lighthouse::Matchers.minimum_score
    port = Lighthouse::Matchers.remote_debugging_port
    runner = Lighthouse::Matchers.runner

    url = target.respond_to?(:current_url) ? target.current_url : target
    opts = "'#{url}' --quiet --output=json #{"--port=#{port}" if port}".strip
    cmd = Lighthouse::Matchers.lighthouse_cli
    output = runner.call("#{cmd} #{opts}")
    results = JSON.parse(output)
    actual_score = results.dig('categories', audit.to_s, 'score') * 100
    actual_score >= score
  end

  failure_message do |target|
    url = target.respond_to?(:current_url) ? target.current_url : target
    <<~FAIL
      expected #{url} to pass Lighthouse #{audit} audit
      with a minimum score of #{score}
    FAIL
  end
end
