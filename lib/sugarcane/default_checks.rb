require 'sugarcane/abc_check'
require 'sugarcane/style_check'
require 'sugarcane/doc_check'
require 'sugarcane/threshold_check'

# Default checks performed when no checks are provided
module SugarCane
  def default_checks
    [
      AbcCheck,
      StyleCheck,
      DocCheck,
      ThresholdCheck
    ]
  end
  module_function :default_checks
end
