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
      check_options(violations, opts)
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

    def check_options(violations, opts)
      if opts[:report]
        outputter.print ViolationFormatter.new(violations, opts)
      elsif opts[:json]
        outputter.print JsonFormatter.new(violations, opts)
      else
        while violations.size > 0
          menu = SugarCane::Menu.new(violations)
          selected = menu.run
          edit_file(selected[:file], selected[:line])
          check_violations
        end
      end
    end

    def outputter
      opts.fetch(:out, $stdout)
    end

    def edit_file(file, line)
      if ENV['VISUAL']
        system("#{ENV['VISUAL']} +#{line} #{file}")
      elsif program_exist? "vim"
        system("vim +#{line} #{file}")
      elsif program_exist? "gedit"
        system("gedit +#{line} #{file}")
      elsif program_exist? "geany"
        system("geany +#{line} #{file}")
      elsif program_exist? "nano"
        system("nano +#{line} #{file}")
      else
        # :(
        system("notepad.exe #{file}")
      end
    end

    def program_exist?(command)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(::File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = ::File.join(path, "#{command}#{ext}")
          return exe if ::File.executable? exe
        }
      end
      return nil
    end
  end
end
