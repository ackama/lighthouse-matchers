# frozen_string_literal: true

require 'lighthouse/matchers/rspec'
require 'lighthouse/audit_service'
require 'tmpdir'

RSpec.describe 'pass_lighthouse_audit matcher' do
  let(:runner) { double }
  let(:example_url) { 'https://example.com' }
  let(:expected_command) do
    "lighthouse-stub '#{example_url}' --quiet --output=json --only-categories=#{audit}"
  end

  let(:audit) { :performance }

  around do |example|
    Lighthouse::Matchers.lighthouse_cli = 'lighthouse-stub'
    Lighthouse::Matchers.runner = runner

    old = Lighthouse::Matchers.results_directory

    Dir.mktmpdir('lighthouse-matchers-') do |tmpdir|
      Lighthouse::Matchers.results_directory = tmpdir

      example.run
    end

    Lighthouse::Matchers.results_directory = old
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
      stub_result(response_fixture(audit, 90))
      expect(example_url).not_to pass_lighthouse_audit(audit)
    end

    it 'passes with a score equal to or greater than threshold' do
      stub_result(response_fixture(audit, 100))
      expect(example_url).to pass_lighthouse_audit(audit)
    end
  end

  context 'with single audit and specified score' do
    let(:audit) { :pwa }
    let(:score) { 50 }

    it 'delegates to the audit service' do
      stub_result(response_fixture(audit, score))
      fake_audit_service = instance_double(AuditService)

      allow(AuditService).to receive(:new).and_return(fake_audit_service)

      allow(fake_audit_service).to receive(:passing_score?).and_return(true)
      allow(fake_audit_service).to receive(:measured_score).and_return(100)
      allow(fake_audit_service).to receive(:run_warnings).and_return([])

      expect(AuditService).to receive_message_chain(:new, :run_warnings)
      expect(AuditService).to receive_message_chain(:new, :passing_score?)
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end

    it 'fails with a score below threshold' do
      stub_result(response_fixture(audit, score - 1))
      expect(example_url).not_to pass_lighthouse_audit(audit, score: score)
    end

    it 'passes with a score equal to the threshold' do
      stub_result(response_fixture(audit, score))
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end

    it 'passes with a score equal to or greater than threshold' do
      stub_result(response_fixture(audit, score + 1))
      expect(example_url).to pass_lighthouse_audit(audit, score: score)
    end

    context 'when it fails' do
      let(:results_file) do
        "#{Lighthouse::Matchers.results_directory}/83e1e62d68a73fedcfaf5c486e3afd5b7a94d559.json"
      end

      it 'raises the correct error' do
        stub_result(response_fixture(audit, score))

        expect do
          expect(example_url).to pass_lighthouse_audit(audit)
        end.to raise_error <<~MESSAGE
          expected #{example_url} to pass Lighthouse #{audit} audit
          with a minimum score of 100, but only scored #{score}

          Full report:
           #{results_file}

           To view this report, load this file into https://googlechrome.github.io/lighthouse/viewer/
        MESSAGE
      end

      it 'writes the results to disk' do
        stub_result(response_fixture(audit, score))

        expect { expect(example_url).to pass_lighthouse_audit(audit) }.to raise_error
        expect { JSON.parse(File.read(results_file)) }.not_to raise_error
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
        command = "#{expected_command} --chrome-flags='--headless --no-sandbox'"

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
    end

    context 'as an array' do
      before { Lighthouse::Matchers.chrome_flags = %w[headless no-sandbox] }

      it 'executes the expected command' do
        command = "#{expected_command} --chrome-flags='--headless --no-sandbox'"

        expect(runner).to receive(:call)
          .with(command)
          .and_return(response_fixture(:performance))

        expect(example_url).to pass_lighthouse_audit(:performance)
      end
    end
  end

  private

  def stub_result(result)
    allow(runner).to receive(:call).with(any_args).and_return(result)
  end

  def response_fixture(audit, score = 100)
    JSON.generate(
      categories: { audit => { score: score / 100.0 } },
      runWarnings: []
    )
  end
end
