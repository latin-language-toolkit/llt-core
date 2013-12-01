require 'spec_helper'
require 'llt/core/api'

describe LLT::Core::Api::Helpers do
  let(:dummy) do
    Class.new { include LLT::Core::Api::Helpers }.new
  end

  describe "#uh" do
    it "unescapes html strings" do
      pending 'Not implemented yet'
    end
  end

  describe "#extract_markup_params" do
    it "extracts the relevant params for markup methods from html params" do
      params = { 'recursive' => true, 'text' => 'test' }
      dummy.extract_markup_params(params).should == [{ recursive: true }]
    end

    it "returns an array that should be exploded when used with #to_xml" do
      params = { recursive: true, tags: %w{ a b }}
      extracted = [%w{ a b }, { recursive: true }]
      dummy.extract_markup_params(params).should == extracted
    end
  end

  describe "#to_xml" do
    it "calls to xml on all elements of a given array and joins them to a string" do
      el1, el2 = double, double
      el1.stub(to_xml: '<a>')
      el2.stub(to_xml: '<b>')
      dummy.to_xml([el1, el2]).should == '<a><b>'
    end
  end
end
