# frozen_string_literal: true

require 'spec_helper'

describe Overcommit::Hook::PreCommit::Pylint do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }
  subject { described_class.new(config, context) }

  before do
    subject.stub(:applicable_files).and_return(%w[file1.py file2.py])
  end

  context 'when pylint exits successfully' do
    before do
      result = double('result')
      result.stub(:success?).and_return(true)
      subject.stub(:execute).and_return(result)
    end

    it { should pass }
  end

  context 'when pylint exits unsucessfully' do
    let(:result) { double('result') }

    before do
      result.stub(:success?).and_return(false)
      subject.stub(:execute).and_return(result)
    end

    context 'and it reports a warning' do
      before do
        result.stub(:stdout).and_return([
          'file1.py:2:C: Missing function docstring (missing-docstring)'
        ].join("\n"))
      end

      it { should warn }
    end

    context 'and it reports an error' do
      before do
        result.stub(:stdout).and_return([
          "file1.py:2:E: Instance of 'Foo' has no 'bar' member (no-member)"
        ].join("\n"))
      end

      it { should fail_hook }
    end
  end
end
