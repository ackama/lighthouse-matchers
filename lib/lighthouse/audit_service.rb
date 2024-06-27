# frozen_string_literal: false

require 'json'
require 'stringio'

# Compares a url's actual score to the expected score.
class AuditService
  class Error < StandardError; end

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

  def measured_score
    category['score'] * 100
  end

  private

  def category
    category = results.dig('categories', @audit.to_s)

    if category.nil?
      raise Error, "Category '#{@audit}' not found in Lighthouse results - maybe it was removed?"
    end

    category
  end

  def opts
    "'#{@url}'".tap do |builder|
      builder << ' --quiet'
      builder << ' --output=json'
      builder << " --only-categories=#{@audit}"
      builder << " --port=#{@port}" if @port
      builder << " --chrome-flags='#{@chrome_flags}'" if @chrome_flags
    end.strip
  end

  def output
    @output ||= @runner.call("#{@cmd} #{opts}")
  end

  def results
    JSON.parse(output)
  end
end
