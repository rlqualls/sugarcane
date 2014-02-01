require 'json'

module SugarCane

  # Computes a machine-readable JSON representation from an array of violations
  # computed by the checks.
  class JsonFormatter
    def initialize(violations, options = {})
      @violations = violations
    end

    def to_s
      @violations.to_json
    end
  end

end
