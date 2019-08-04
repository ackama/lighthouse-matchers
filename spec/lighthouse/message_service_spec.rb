# frozen_string_literal: true

require 'lighthouse/message_service'

RSpec.describe MessageService do
  let(:url)   { 'example.com' }
  let(:audit) { :performance }
  let(:score) { 75 }

  subject { described_class.new(url, audit, score) }

  describe '#audit_fail_message' do
    it 'returns the expected string' do
      expect(subject.audit_fail_message)
        .to eq "expected #{url} to pass Lighthouse #{audit} audit\n"\
        "with a minimum score of #{score}\n"
    end

    context 'with three other arguments' do
      let(:url)   { 'new_example.com' }
      let(:audit) { :pwa }
      let(:score) { 60 }

      it 'returns the expect string' do
        expect(subject.audit_fail_message)
          .to eq "expected #{url} to pass Lighthouse #{audit} audit\n"\
          "with a minimum score of #{score}\n"
      end
    end

    context 'when all arguments are nil' do
      let(:url)   { nil }
      let(:audit) { nil }
      let(:score) { nil }

      it 'returns the expected string' do
        expect(subject.audit_fail_message)
          .to eq "expected #{url} to pass Lighthouse #{audit} audit\n"\
          "with a minimum score of #{score}\n"
      end
    end
  end
end
