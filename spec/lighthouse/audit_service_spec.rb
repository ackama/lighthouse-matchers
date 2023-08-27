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
        stub_command(response_fixture(audit, score))
        expect(subject.passing_score?).to eq true
      end
    end

    context 'when the score is below the threshold' do
      it 'returns false' do
        stub_command(response_fixture(audit, score - 1))
        expect(subject.passing_score?).to eq false
      end
    end

    context 'when the score is above the threshold' do
      it 'returns true' do
        stub_command(response_fixture(audit, score + 1))
        expect(subject.passing_score?).to eq true
      end
    end
  end

  private

  def stub_command(result)
    allow(runner)
      .to receive(:call)
      .with("lighthouse-stub 'example.com' --quiet --output=json")
      .and_return(result)
  end

  def response_fixture(audit, score)
    JSON.generate(categories: { audit => { score: score / 100.0 } })
  end
end
