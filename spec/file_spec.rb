require 'spec_helper'
require 'tmpdir'

require 'sugarcane/file'

describe SugarCane::File do
  describe '.case_insensitive_glob' do
    it 'matches all kinds of readmes' do
      expected = %w(
        README
        readme.md
        ReaDME.TEXTILE
      )

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          expected.each do |x|
            FileUtils.touch(x)
          end
          SugarCane::File.case_insensitive_glob("README*").should =~ expected
        end
      end
    end
  end
end
