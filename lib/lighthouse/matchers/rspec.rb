# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'lighthouse/audit_service'
require 'json'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, score: nil|
  score ||= Lighthouse::Matchers.minimum_score

  match do |target|
    AuditService.new(url(target), audit, score).passing_score?
  end

  failure_message do |target|
    <<~FAIL
      expected #{url(target)} to pass Lighthouse #{audit} audit
      with a minimum score of #{score}
    FAIL
  end

  private

  def url(target)
    target.respond_to?(:current_url) ? target.current_url : target
  end
end
