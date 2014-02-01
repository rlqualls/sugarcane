require 'sugarcane/cli/parser'
require 'sugarcane/runner'
require 'sugarcane/version'
require 'sugarcane/file'

module SugarCane
  # Command line interface. This passes off arguments to the parser and starts
  # the Cane runner
  module CLI
    def run(args)
      spec = Parser.parse(args)
      if spec.is_a?(Hash)
        SugarCane.run(spec)
      else
        spec
      end
    end
    module_function :run

  end
end
