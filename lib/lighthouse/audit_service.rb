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
  end

  def passing_score?
    measured_score >= @score
  end

  private

  def opts
    "'#{@url}'".tap do |builder|
      builder << ' --quiet'
      builder << ' --output=json'
      builder << " --port=#{@port}" if @port
      builder << " --chrome-flags='#{@chrome_flags}'" if @chrome_flags
    end.strip
  end

  def output
    @runner.call("#{@cmd} #{opts}")
  end

  def results
    puts output
    JSON.parse(output)
  end

  def measured_score
    results.dig('categories', @audit.to_s, 'score') * 100
  end
end
