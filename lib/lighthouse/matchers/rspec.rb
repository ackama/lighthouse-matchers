# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'lighthouse/audit_service'
require 'json'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, args = {}|
  score ||= args.fetch(:score, Lighthouse::Matchers.minimum_score)

  match do |target|
    @audit_service = AuditService.new(url(target), audit, score)
    @audit_service.passing_score?
  end

  failure_message do |target|
    <<~FAIL
      expected #{url(target)} to pass Lighthouse #{audit} audit
      with a minimum score of #{score}, but only scored #{@audit_service.measured_score}.

      #{JSON.pretty_generate(@audit_service.results)}

      To view this report, load this json into https://googlechrome.github.io/lighthouse/viewer/
    FAIL
  end

  private

  def url(target)
    target.respond_to?(:current_url) ? target.current_url : target
  end
end
