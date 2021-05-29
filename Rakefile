# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.rspec_opts = '--tag type:integration'
  end

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = '--tag ~type:integration'
  end
end

task default: :spec
