# frozen_string_literal: true

require 'lighthouse/matchers/rspec'

RSpec.describe 'pass_lighthouse_audit matcher' do
  let(:runner) { double }
  let(:example_url) { 'https://example.com' }
  let(:expected_command) { "lighthouse-stub '#{example_url}' --quiet --output=json" }

  before do
    Lighthouse::Matchers.lighthouse_cli = 'lighthouse-stub'
    Lighthouse::Matchers.runner = runner
  end

  context 'with single audit and default score' do
    let(:audit) { :performance }
    subject { example_url }

    it 'executes the expected command' do
      expect(runner).to receive(:call)
        .with(expected_command)
        .and_return(response_fixture(audit))

      expect(example_url).to pass_lighthouse_audit(audit)
    end

    it 'fails with a score below threshold' do
      stub_command(expected_command, response_fixture(audit, 90))
      expect(example_url).not_to pass_lighthouse_audit(audit)
    end

    it 'passes with a score equal to or greater than threshold' do
      stub_command(expected_command, response_fixture(audit, 100))
      expect(example_url).to pass_lighthouse_audit(audit)
    end
  end

  context 'with single audit and specified score' do
    let(:audit) { :pwa }
    let(:score) { 50 }

    it 'fails with a score below threshold' do
      stub_command(expected_command, response_fixture(audit, score - 1))
      expect(example_url).not_to pass_lighthouse_audit(audit, score: score)
    end

    it 'passes with a score equal to the threshold' do
      stub_command(expected_command, response_fixture(audit, score))
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end

    it 'passes with a score equal to or greater than threshold' do
      stub_command(expected_command, response_fixture(audit, score + 1))
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end
  end

  context 'with custom command specified' do
    it 'executes the expected command' do
      Lighthouse::Matchers.lighthouse_cli = 'custom-lighthouse-command'
      expect(runner).to receive(:call)
        .with(expected_command.gsub('lighthouse-stub', 'custom-lighthouse-command'))
        .and_return(response_fixture(:performance))

      expect(example_url).to pass_lighthouse_audit(:performance)
    end
  end

  private

  def stub_command(cmd, result)
    allow(runner).to receive(:call).with(cmd).and_return(result)
  end

  def response_fixture(audit, score = 100)
    JSON.generate(categories: { audit => { score: score / 100.0 } })
  end
end
