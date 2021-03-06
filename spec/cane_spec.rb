require 'spec_helper'
require "stringio"
require 'sugarcane/cli'
require 'sugarcane/menu'

require 'sugarcane/rake_task'
require 'sugarcane/task_runner'

# Acceptance tests
describe 'The sugarcane application' do
  let(:class_name) { "C#{rand(10 ** 10)}" }

  let(:fn) do
    make_file(<<-RUBY + "  ")
      class Harness
        def complex_method(a)
          if a < 2
            return "low"
          else
            return "high"
          end
        end
      end
    RUBY
  end

  let(:check_file) do
    make_file <<-RUBY
      class #{class_name} < Struct.new(:opts)
        def self.options
          {
            unhappy_file: ["File to check", default: [nil]]
          }
        end

        def violations
          [
            description: "Files are unhappy",
            file:        opts.fetch(:unhappy_file),
            label:       ":("
          ]
        end
      end
    RUBY
  end

  it 'returns a non-zero exit code and a details of checks that failed' do
    output, exitstatus = run %(
      --report
      --style-glob #{fn}
      --doc-glob #{fn}
      --abc-glob #{fn}
      --abc-max 1
      -r #{check_file}
      --check #{class_name}
      --unhappy-file #{fn}
    )
    output.should include("Lines violated style requirements")
    output.should include("Methods exceeded maximum allowed ABC complexity")
    output.should include(
      "Class and Module definitions require explanatory comments"
    )
    exitstatus.should == 1
  end

  it 'should not show methods within the expected ABC complexity' do
    output, exitstatus = run %(
      --report
      --style-glob #{fn}
      --doc-glob #{fn}
      --abc-glob #{fn}
      --abc-max 10
      -r #{check_file}
      --check #{class_name}
      --unhappy-file #{fn}
    )
    output.should include("Lines violated style requirements")
    output.should_not include("Methods exceeded maximum allowed ABC complexity")
    output.should include(
      "Class and Module definitions require explanatory comments"
    )
    exitstatus.should == 1
  end

  it 'creates a menu' do
    pending "Make a unit test or find a way to create artificial key presses"
    output, exitstatus = run %(
      --style-glob #{fn}
      --doc-glob #{fn}
      --abc-glob #{fn}
      --abc-max 1
      -r #{check_file}
      --check #{class_name}
      --unhappy-file #{fn}
    )

    exitstatus.should == 1
  end

  it 'handles invalid unicode input' do
    fn = make_file("\xc3\x28")

    _, exitstatus = run("--style-glob #{fn} --abc-glob #{fn} --doc-glob #{fn}")

    exitstatus.should == 0
  end

  it 'can run tasks in parallel' do
    # This spec isn't great, but there is no good way to actually observe that
    # tasks run in parallel and we want to verify the conditional is correct.
    SugarCane.task_runner(parallel: true).should == Parallel
  end

  it 'colorizes output' do
    output, exitstatus = run("--report --color --abc-max 0")

    output.should include("\e[31m")
  end

  after do
    if Object.const_defined?(class_name)
      Object.send(:remove_const, class_name)
    end
  end

  def run(cli_args)
    result = nil
    output = capture_stdout do
      result = SugarCane::CLI.run(
        %w(--no-abc --no-style --no-doc) + cli_args.split(/\s+/m)
      )
    end

    [output, result ? 0 : 1]
  end
end
