require 'spec_helper'
require 'sugarcane/json_formatter'

describe SugarCane::JsonFormatter do
  it 'outputs violations as JSON' do
    violations = [{description: 'Fail', line: 3}]
    JSON.parse(described_class.new(violations).to_s).should ==
      [{'description' => 'Fail', 'line' => 3}]
  end
end
