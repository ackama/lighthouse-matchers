# frozen_string_literal: true

require 'lighthouse/matchers/version'

module Lighthouse
  ##
  # Defines configuration and behaviours that are shared across the entire
  # Lighthouse::Matchers namespace
  module Matchers
    class Error < StandardError; end
    class << self
      attr_writer :minimum_score,
                  :remote_debugging_port,
                  :lighthouse_cli,
                  :runner
      attr_reader :remote_debugging_port

      def minimum_score
        @minimum_score ||= default_minimum_score
      end

      def lighthouse_cli
        @lighthouse_cli ||= lighthouse_cli
      end

      def runner
        @runner ||= Kernel.method(:system)
      end

      private

      def guess_lighthouse_cli
        [
          `which lighthouse` || '',
          'node_modules/.bin/lighthouse',
          'node_modules/bin/lighthouse'
        ].find { |loc| File.exist?(loc) }
      end

      def default_minimum_score
        100
      end
    end
  end
end
