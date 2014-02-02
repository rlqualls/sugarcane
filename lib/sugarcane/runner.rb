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
  # application, but for the actual entry point see `Cane::CLI`.
  class Runner
    def initialize(spec)
      @opts = spec
      @checks = spec[:checks]
    end

    def run
      while violations.size > 0
        menu = SugarCane::Menu.new(violations)
        selected = menu.run
        system("vim +#{selected[:line]} #{selected[:file]}")
        check_violations
      end
      # outputter.print formatter.new(violations, opts)
      violations.length <= opts.fetch(:max_violations)
    end

    protected

    attr_reader :opts, :checks

    def violations
      @violations ||= checks.
        map {|check| check.new(opts).violations }.
        flatten
    end

    def check_violations
      @violations = checks.
        map {|check| check.new(opts).violations }.
        flatten
    end

    def outputter
      opts.fetch(:out, $stdout)
    end

    def formatter
      if opts[:json]
        JsonFormatter
      else
        ViolationFormatter
      end
    end
  end
end
