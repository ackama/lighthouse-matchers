# frozen_string_literal: true

require 'lighthouse/matchers/version'

##
# Defines configuration and behaviours that are shared across the entire
# Lighthouse::Matchers namespace
module Lighthouse
  module Matchers # rubocop:disable Style/Documentation
    class Error < StandardError; end
    class << self
      attr_writer :minimum_score,
                  :remote_debugging_port,
                  :lighthouse_cli,
                  :runner,
                  :lighthouse_options,
                  :chrome_flags
      attr_reader :remote_debugging_port

      def minimum_score
        @minimum_score ||= default_minimum_score
      end

      def lighthouse_cli
        @lighthouse_cli ||= guess_lighthouse_cli
      end

      def runner
        @runner ||= proc { |cmd| `#{cmd}` }
      end

      def lighthouse_options
        return unless @lighthouse_options
        return @lighthouse_options unless @lighthouse_options.is_a?(Array)

        @lighthouse_options.map { |f| "--#{f}" }.join(' ')
      end

      def chrome_flags
        return unless @chrome_flags
        return @chrome_flags unless @chrome_flags.is_a?(Array)

        @chrome_flags.map { |f| "--#{f}" }.join(' ')
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
