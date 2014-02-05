require 'parallel'

require 'sugarcane/violation_formatter'
require 'sugarcane/json_formatter'
require 'sugarcane/menu'

# Accepts a parsed configuration and passes those options to a new Runner
module SugarCane
  def run(*args)
    Runner.new(*args).run
  end
  module_function :run

  # Orchestrates the running of checks per the provided configuration, and
  # hands the result to a formatter for display. This is the core of the
  # application, but for the actual entry point see `SugarCane::CLI`.
  class Runner
    def initialize(spec)
      @opts = spec
      @checks = spec[:checks]
    end

    def run
      check_options(violations, opts)
      violations.length <= opts.fetch(:max_violations)
    end

    protected

    attr_reader :opts, :checks

    def violations
      @violations ||= checks.
        map { |check| check.new(opts).violations }.
        flatten
    end

    def check_violations
      @violations = checks.
        map { |check| check.new(opts).violations }.
        flatten
    end

    def check_options(violations, opts)
      if opts[:report]
        outputter.print ViolationFormatter.new(violations, opts)
      elsif opts[:json]
        outputter.print JsonFormatter.new(violations, opts)
      else
        menu = SugarCane::Menu.new(@checks, @opts)
        menu.run
      end
    end

    def outputter
      opts.fetch(:out, $stdout)
    end
  end
end
