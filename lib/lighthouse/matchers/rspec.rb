# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'lighthouse/audit_service'
require 'json'
require 'digest'
require 'fileutils'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, args = {}| # rubocop:disable Metrics/BlockLength
  score ||= args.fetch(:score, Lighthouse::Matchers.minimum_score)

  match do |target|
    @audit_service = AuditService.new(url(target), audit, score)

    @audit_service.run_warnings.each do |warning|
      RSpec.configuration.reporter.message(
        "#{RSpec.current_example.full_description}: [lighthouse] #{warning}"
      )
    end

    @measured_score = @audit_service.measured_score

    @audit_service.passing_score?
  end

  failure_message do |target|
    <<~FAIL
      expected #{url(target)} to pass Lighthouse #{audit} audit
      with a minimum score of #{score}, but only scored #{@measured_score.to_i}

      Full report:
       #{save_audit_results}

       To view this report, load this file into https://googlechrome.github.io/lighthouse/viewer/
    FAIL
  end

  private

  def url(target)
    target.respond_to?(:current_url) ? target.current_url : target
  end

  def save_audit_results
    body = JSON.pretty_generate(@audit_service.results)

    path = File.join(Lighthouse::Matchers.results_directory, "#{Digest::SHA1.hexdigest(body)}.json")

    FileUtils.mkdir_p(Lighthouse::Matchers.results_directory)
    File.write(path, body)

    path
  end
end
