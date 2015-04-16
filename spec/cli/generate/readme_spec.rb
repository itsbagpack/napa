require 'spec_helper'
require 'napa/cli/generate/readme'

describe Napa::CLI::Generate do
  let(:test_readme_directory) { 'spec/tmp' }

  silence_thor

  before do
    allow_any_instance_of(described_class).to receive(:output_directory).and_return(test_readme_directory)
    Napa::CLI::Generate.new.readme
  end

  after do
    FileUtils.rm_rf(test_readme_directory)
  end

  describe 'README' do
    it 'creates a README in the current directory' do
      expected_readme_file = File.join(test_readme_directory, 'README.md')
      readme = File.read(expected_readme_file)

      expect(readme).to match /# #{Napa::Identity.name}/
    end
  end

  describe 'spec' do
    it 'creates a README spec' do
      expected_spec_file = File.join(test_readme_directory, 'spec/docs/readme_spec.rb')
      spec_code = File.read(expected_spec_file)

      expect(spec_code).to match(/describe \'README\'/)
    end
  end

end
