require 'spec_helper'
require 'sugarcane/cli'

describe SugarCane::CLI do
  describe '.run' do

    let!(:parser) { class_double("SugarCane::CLI::Parser").as_stubbed_const }
    let!(:cane)   { class_double("SugarCane").as_stubbed_const }

    it 'runs SugarCane with the given arguments' do
      parser.should_receive(:parse).with("--args").and_return(args: true)
      cane.should_receive(:run).with(args: true).and_return("tracer")

      described_class.run("--args").should == "tracer"
    end

    it 'does not run SugarCane if parser was able to handle input' do
      parser.should_receive(:parse).with("--args").and_return("tracer")

      described_class.run("--args").should == "tracer"
    end
  end
end
