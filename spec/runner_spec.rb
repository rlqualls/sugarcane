require 'spec_helper'
require 'sugarcane/runner'

describe SugarCane::Runner do
  describe '#run' do
    it 'returns true iff fewer violations than max allowed' do
      described_class.new(checks: [], max_violations: 0).run.should be
      described_class.new(checks: [], max_violations: -1).run.should_not be
    end

    it 'returns JSON output' do
      formatter = class_double("SugarCane::JsonFormatter").as_stubbed_const
      formatter.should_receive(:new).and_return("JSON")
      buffer = StringIO.new("")

      described_class.new(
        out: buffer, checks: [], max_violations: 0, json: true
      ).run

      buffer.string.should == "JSON"
    end
  end
end
