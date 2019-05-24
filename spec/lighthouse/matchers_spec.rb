# frozen_string_literal: true

RSpec.describe Lighthouse::Matchers do
  it 'has a version number' do
    expect(Lighthouse::Matchers::VERSION).not_to be nil
  end
end
