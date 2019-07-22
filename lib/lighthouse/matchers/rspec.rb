# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'lighthouse/message_service'
require 'lighthouse/audit_service'
require 'json'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, score: nil|
  match do |target|
    AuditService.new(url(target), audit, score(score)).passing_score?
  end

  failure_message do |target|
    MessageService.new(url(target), audit, score(score)).audit_fail_message
  end

  private

  def url(target)
    target.respond_to?(:current_url) ? target.current_url : target
  end

  def score(score)
    score || Lighthouse::Matchers.minimum_score
  end
end
