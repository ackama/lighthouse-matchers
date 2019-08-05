# frozen_string_literal: true

require 'json'

# Compares a url's actual score to the expected score.
class AuditService
  def initialize(url, audit, score)
    @url = url
    @audit = audit
    @score = score
    @port = Lighthouse::Matchers.remote_debugging_port
    @runner = Lighthouse::Matchers.runner
    @cmd = Lighthouse::Matchers.lighthouse_cli
  end

  def passing_score?
    measured_score >= @score
  end

  private

  def opts
    "'#{@url}' --quiet --output=json #{"--port=#{@port}" if @port}".strip
  end

  def output
    @runner.call("#{@cmd} #{opts}")
  end

  def results
    JSON.parse(output)
  end

  def measured_score
    results.dig('categories', @audit.to_s, 'score') * 100
  end
end
