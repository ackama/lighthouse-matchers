# frozen_string_literal: true

require 'lighthouse/matchers/rspec'
require 'lighthouse/audit_service'

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

    it 'delegates to the audit service' do
      stub_command(expected_command, response_fixture(audit, score))
      allow(AuditService).to receive_message_chain(:new, :passing_score?).and_return(true)
      expect(AuditService).to receive_message_chain(:new, :passing_score?)
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end

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

    context 'when it fails' do
      it 'raises the correct error' do
        stub_command(expected_command, response_fixture(audit, score))
        expect do
          expect(example_url).to pass_lighthouse_audit(audit)
        end.to raise_error("expected #{example_url} to pass Lighthouse #{audit} audit\n"\
                           "with a minimum score of 100, current score is #{score}\n")
      end
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

  context 'with Chrome flags specified' do
    context 'as a string' do
      before { Lighthouse::Matchers.chrome_flags = '--headless --no-sandbox' }

      it 'executes the expected command' do
        command = expected_command + " --chrome-flags='--headless --no-sandbox'"

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
    end

    context 'as an array' do
      before { Lighthouse::Matchers.chrome_flags = %w[headless no-sandbox] }

      it 'executes the expected command' do
        command = expected_command + " --chrome-flags='--headless --no-sandbox'"

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
    end
  end

  context 'with Lighthouse Options specified' do
    before { Lighthouse::Matchers.chrome_flags = nil }

    context 'as a string' do
      before { Lighthouse::Matchers.lighthouse_options = '--throttling-method=provided' }

      it 'executes the expected command' do
        command = expected_command + ' --throttling-method=provided'

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
    end

    context 'as an array' do
      before { Lighthouse::Matchers.lighthouse_options = %w[emulated-form-factor=desktop] }

      it 'executes the expected command' do
        command = expected_command + ' --emulated-form-factor=desktop'

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
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
