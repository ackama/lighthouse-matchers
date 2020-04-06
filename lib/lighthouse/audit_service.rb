# frozen_string_literal: false

require 'json'
require 'stringio'

# Compares a url's actual score to the expected score.
class AuditService
  def initialize(url, audit, score)
    @url = url
    @audit = audit
    @score = score
    @port = Lighthouse::Matchers.remote_debugging_port
    @runner = Lighthouse::Matchers.runner
    @cmd = Lighthouse::Matchers.lighthouse_cli
    @chrome_flags = Lighthouse::Matchers.chrome_flags
    @lighthouse_options = Lighthouse::Matchers.lighthouse_options
  end

  def passing_score?
    measured_score >= @score
  end

  def measured_score
    results.dig('categories', @audit.to_s, 'score') * 100
  end

  private

  def opts
    "'#{@url}'".tap do |builder|
      builder << ' --quiet'
      builder << ' --output=json'
      builder << " --port=#{@port}" if @port
      builder << " --chrome-flags='#{@chrome_flags}'" if @chrome_flags
      builder << " #{@lighthouse_options}" if @lighthouse_options
    end.strip
  end

  def output
    @runner.call("#{@cmd} #{opts}")
  end

  def results
    JSON.parse(output)
  end
end
