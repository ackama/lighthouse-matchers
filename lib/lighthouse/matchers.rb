# frozen_string_literal: true

require 'lighthouse/matchers/version'

##
# Defines configuration and behaviours that are shared across the entire
# Lighthouse::Matchers namespace
module Lighthouse
  module Matchers # rubocop:disable Style/Documentation
    class Error < StandardError; end
    class << self
      attr_writer :minimum_score, :lighthouse_cli, :runner, :chrome_flags, :results_directory
      attr_accessor :remote_debugging_port

      def minimum_score
        @minimum_score ||= default_minimum_score
      end

      def lighthouse_cli
        @lighthouse_cli ||= guess_lighthouse_cli
      end

      def runner
        @runner ||= proc { |cmd| `#{cmd}` }
      end

      def chrome_flags
        return unless @chrome_flags
        return @chrome_flags unless @chrome_flags.is_a?(Array)

        @chrome_flags.map { |f| "--#{f}" }.join(' ')
      end

      def results_directory
        @results_directory ||= if defined?(Rspec)
          File.join(RSpec.configuration.default_path, 'lighthouse_results')
        else
          Dir.mktmpdir
        end
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
