#!/usr/bin/env rake
require "bundler/gem_tasks"
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |c|
    c.rspec_opts = "--profile"
  end

  task :default => :spec
rescue LoadError
  warn "rspec not available, spec task not provided"
end

begin
  require 'sugarcane/rake_task'

  desc "Run cane to check quality metrics"
  SugarCane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 35
    # There doesn't seem to be a coverage threshold defined
    # cane.add_threshold 'coverage/covered_percent', :>=, 70
  end

  task :default => :quality
rescue LoadError
  warn "sugarcane not available, quality task not provided."
end
