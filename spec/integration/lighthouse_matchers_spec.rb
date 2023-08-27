# frozen_string_literal: true

require 'spec_helper'
require 'webrick'

RSpec.describe 'LighthouseMatchers', type: :integration do
  before(:all) do
    @original_chrome_flags = Lighthouse::Matchers.chrome_flags
    Lighthouse::Matchers.chrome_flags = ENV['CI_CHROME_FLAGS']

    dev_null = WEBrick::Log.new('/dev/null', 7)

    @root = File.expand_path("#{__dir__}/../fixtures")
    @pid = fork do
      WEBrick::HTTPServer.new(
        Port: 8000,
        Logger: dev_null,
        AccessLog: dev_null,
        DocumentRoot: @root
      ).start
    end
  end

  after(:all) do
    Lighthouse::Matchers.chrome_flags = @original_chrome_flags
    Process.kill('QUIT', @pid)
  end

  subject { "http://localhost:8000/#{fixture}" }

  context 'a passing accessibility audit' do
    let(:fixture) { 'accessibility_passing.html' }
    it { is_expected.to pass_lighthouse_audit(:accessibility) }
  end

  context 'a failing accessibility audit' do
    let(:fixture) { 'accessibility_failing.html' }
    it { is_expected.not_to pass_lighthouse_audit(:accessibility) }
  end

  context 'a passing performance audit' do
    let(:fixture) { 'performance_passing.html' }
    it { is_expected.to pass_lighthouse_audit(:performance) }
  end
end
