# frozen_string_literal: true

require 'rspec/expectations'
require 'lighthouse/matchers'
require 'lighthouse/audit_service'
require 'json'

RSpec::Matchers.define :pass_lighthouse_audit do |audit, args = {}|
  score ||= args.fetch(:score, Lighthouse::Matchers.minimum_score)

  match do |target|
    @audit_service = AuditService.new(url(target), audit, score)

    @audit_service.run_warnings.each do |warning|
      RSpec.configuration.reporter.message("#{RSpec.current_example.location}: #{warning}")
    end

    puts "saved results to #{save_audit_results}"
    @audit_service.passing_score?
  end

  failure_message do |target|
    <<~FAIL
      expected #{url(target)} to pass Lighthouse #{audit} audit
      with a minimum score of #{score}, but only scored #{@audit_service.measured_score}

     Full report:
      #{save_audit_results}

      To view this report, load this file into https://googlechrome.github.io/lighthouse/viewer/
    FAIL
  end

  private

  def save_audit_results
    @audit_results_path ||= write_file(JSON.pretty_generate(@audit_service.results))
  end

  def write_file(body)
    path = File.join(Lighthouse::Matchers.results_directory, "#{Digest::SHA1.hexdigest(body)}.json")

    FileUtils.mkdir_p(Lighthouse::Matchers.results_directory)
    File.write(path, body)

    path
  end

  def url(target)
    target.respond_to?(:current_url) ? target.current_url : target
  end
end
