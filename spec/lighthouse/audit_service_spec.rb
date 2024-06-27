# frozen_string_literal: true

require 'lighthouse/audit_service'

RSpec.describe AuditService do
  let(:runner) { double }
  let(:url)    { 'example.com' }
  let(:audit)  { :performance }
  let(:score)  { 75 }

  subject { described_class.new(url, audit, score) }

  before do
    Lighthouse::Matchers.lighthouse_cli = 'lighthouse-stub'
    Lighthouse::Matchers.runner = runner
  end

  describe '#passing_score?' do
    context 'when the score matches' do
      it 'returns true' do
        stub_command(response_fixture)
        expect(subject.passing_score?).to eq true
      end
    end

    context 'when the score is below the threshold' do
      it 'returns false' do
        stub_command(response_fixture(score - 1))
        expect(subject.passing_score?).to eq false
      end
    end

    context 'when the score is above the threshold' do
      it 'returns true' do
        stub_command(response_fixture(score + 1))
        expect(subject.passing_score?).to eq true
      end
    end

    context 'when the category is not found' do
      it 'raises an error' do
        stub_command(JSON.generate(categories: {}))
        expect { subject.measured_score }.to raise_error(
          AuditService::Error,
          "Category '#{audit}' not found in Lighthouse results - maybe it was removed?"
        )
      end
    end
  end

  describe '#measured_score' do
    context 'when the category does exist' do
      it 'returns the score as a percentage' do
        stub_command(response_fixture)
        expect(subject.measured_score).to eq score
      end
    end

    context 'when the category is not found' do
      it 'raises an error' do
        stub_command(JSON.generate(categories: {}))
        expect { subject.measured_score }.to raise_error(
          AuditService::Error,
          "Category '#{audit}' not found in Lighthouse results - maybe it was removed?"
        )
      end
    end
  end

  private

  def stub_command(result)
    allow(runner)
      .to receive(:call)
      .with("lighthouse-stub 'example.com' --quiet --output=json --only-categories=#{audit}")
      .and_return(result)
  end

  def response_fixture(result_score = score)
    JSON.generate(categories: { audit => { score: result_score / 100.0 } })
  end
end
