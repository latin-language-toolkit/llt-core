require 'spec_helper'

describe LLT::Core::Versioner do
  # The version module is included by Version classes exclusively.
  # We can therefore test its behaviour directly in the Core's own
  # Version class.
  let(:version) { LLT::Core::Version.new }

  describe "#source" do
    it "returns the path to the (GitHub) repository" do
      version.source.should == 'https://github.com/latin-language-toolkit/llt-core'
    end
  end

  describe "#version" do
    it "returns the gem's version" do
      version.version.should == LLT::Core::VERSION
    end
  end

  describe "#to_xml" do
    it "provides version info in xml format" do
      result = %{<gem name="#{version.gem_name}" version="#{version.version}"><source href="#{version.source}"/></gem>}
      version.to_xml.should == result
    end
  end
end
