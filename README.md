[![Build Status](https://travis-ci.org/rlqualls/sugarcane.png?branch=master)](https://travis-ci.org/rlqualls/sugarcane)
[![Coverage Status](https://coveralls.io/repos/rlqualls/sugarcane/badge.png)](https://coveralls.io/r/rlqualls/sugarcane)
[![Code Climate](https://codeclimate.com/github/rlqualls/sugarcane.png)](https://codeclimate.com/github/rlqualls/sugarcane)

![sugarcane screenshot](http://i.imgur.com/RP7xDLU.png)

> It's best to get beat with something sweet...

You can find the original project at [square/cane](https://github.com/square/cane)

## Features

  - Go straight from violations to their lines in a text editor
  - Otherwise does what cane does

## Controls

(Arrow keys aren't working yet)

  - K,W, UP - up
  - J,S, DOWN - down
  - Q,X - quit
  - O, Enter, Space - open file in text editor at the violation

## Installation (for now)

    $ git clone https://github.com/rlqualls/sugarcane
    $ cd sugarcane
    $ bundle
    $ rake install

## Usage Examples

To run the default checks on all files in your project, navigate to the 
project root and run sugarcane

    $ sugarcane

If you just want to run all checks on a specific file:

    $ sugarcane -f README.md

If you want to run checks on files matching a pattern:

    $ sugarcane --abc-glob '{lib,spec}/**/*.rb' --abc-max 15

Sugarcane tries to find an editor in your PATH, choosing vim first if it's
available. You can specify a different editor, though:

    $ sugarcane --editor nano
    $ sugarcane --editor=gedit

Maybe you don't want the menu. For original `cane` functionality, add 
the --report option

    $ sugarcane --report

    Methods exceeded maximum allowed ABC complexity (2):

      lib/sugarcane.rb  Cane#sample    23
      lib/sugarcane.rb  Cane#sample_2  17

    Lines violated style requirements (2):

      lib/sugarcane.rb:20   Line length >80
      lib/sugarcane.rb:42   Trailing whitespace

    Class definitions require explanatory comments on preceding line (1):
      lib/sugarcane:3  SomeClass

Customize behavior with a wealth of options:

    $ sugarcane --help
    Usage: sugarcane [options]

    Default options are loaded from a .sugarcane file in the current directory.

    -r, --require FILE               Load a Ruby file containing user-defined checks
    -c, --check CLASS                Use the given user-defined check

        --abc-glob GLOB              Glob to run ABC metrics over (default: {app,lib}/**/*.rb)
        --abc-max VALUE              Ignore methods under this complexity (default: 15)
        --abc-exclude METHOD         Exclude method from analysis (eg. Foo::Bar#method)
        --no-abc                     Disable ABC checking

        --style-glob GLOB            Glob to run style checks over (default: {app,lib,spec}/**/*.rb)
        --style-measure VALUE        Max line length (default: 80)
        --style-exclude GLOB         Exclude file or glob from style checking
        --no-style                   Disable style checking

        --doc-glob GLOB              Glob to run doc checks over (default: {app,lib}/**/*.rb)
        --doc-exclude GLOB           Exclude file or glob from documentation checking
        --no-readme                  Disable readme checking
        --no-doc                     Disable documentation checking

        --lt FILE,THRESHOLD          Check the number in FILE is < to THRESHOLD (a number or another file name)
        --lte FILE,THRESHOLD         Check the number in FILE is <= to THRESHOLD (a number or another file name)
        --eq FILE,THRESHOLD          Check the number in FILE is == to THRESHOLD (a number or another file name)
        --gte FILE,THRESHOLD         Check the number in FILE is >= to THRESHOLD (a number or another file name)
        --gt FILE,THRESHOLD          Check the number in FILE is > to THRESHOLD (a number or another file name)

    -f, --all FILE                   Apply all checks to given file
        --max-violations VALUE       Max allowed violations (default: 0)
        --json                       Output as JSON
        --report                     Original cane output
        --parallel                   Use all processors. Slower on small projects, faster on large.
        --color                      Colorize output

    -v, --version                    Show version
    -h, --help                       Show this message

Set default options using a `.cane` file:

    $ cat .cane
    --no-doc
    --abc-glob **/*.rb
    $ sugarcane

It works exactly the same as specifying the options on the command-line.
Command-line arguments will override arguments specified in the `.cane` file.

## Integrating with Rake

```ruby
begin
  require 'sugarcane/rake_task'

  desc "Run cane to check quality metrics"
  SugarCane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 10
    cane.no_style = true
    cane.abc_exclude = %w(Foo::Bar#some_method)
  end

  task :default => :quality
rescue LoadError
  warn "sugarcane not available, quality task not provided."
end
```

Loading options from a `.cane` file is supported by setting `canefile=` to the
file name.

Rescuing `LoadError` is a good idea, since `rake -T` failing is totally
frustrating.

## Implementing your own checks

Checks must implement:

* A class level `options` method that returns a hash of available options. This
  will be included in help output if the check is added before `--help`. If
  your check does not require any configuration, return an empty hash.
* A one argument constructor, into which will be passed the options specified
  for your check.
* A `violations` method that returns an array of violations.

See existing checks for guidance. Create your check in a new file:

```ruby
# unhappy.rb
class UnhappyCheck < Struct.new(:opts)
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
```

Include your check either using command-line options:

    sugarcane -r unhappy.rb --check UnhappyCheck --unhappy-file myfile

Or in your rake task:

```ruby
require 'unhappy'

SugarCane::RakeTask.new(:quality) do |c|
  c.use UnhappyCheck, unhappy_file: 'myfile'
end
```
## Compatibility

Requires MRI 1.9, since it depends on the `ripper` library to calculate
complexity metrics. This only applies to the Ruby used to run SugarCane, not the
project it is being run against. In other words, you can run Cane against your
1.8 or JRuby project.

## Support

Make a [new github issue](https://github.com/rlqualls/sugarcane/issues/new).
