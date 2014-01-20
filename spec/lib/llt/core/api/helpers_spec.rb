require 'spec_helper'
require 'llt/core/api'

describe LLT::Core::Api::Helpers do
  let(:dummy) do
    Class.new { include LLT::Core::Api::Helpers }.new
  end

  describe "#extract_text" do
    context "text param" do
      it "tries to resolve a passed or a given text param" do
       dummy.extract_text(:text => "some text").should == "some text"
      end

      it "strips away the xml declaration" do
       dummy.extract_text(:text => %{<?xml version="1.0" encoding="UTF-8"?>some text}).should == "some text"
      end
    end

    context "uri param" do
      it "calls to the given URI to retrieve the text" do
        allow(dummy).to receive(:get_from_uri) { "text from uri" }
        dummy.extract_text(:uri => "some uri").should == "text from uri"
      end

      it "strips away the xml declaration" do
        allow(dummy).to receive(:get_from_uri) { %{<?xml version="1.0" encoding="UTF-8"?>text from uri} }
        dummy.extract_text(:uri => "some uri").should == "text from uri"
      end
    end
  end

  describe "#extract_markup_params" do
    it "extracts the relevant params for markup methods from html params" do
      params = { 'recursive' => true, 'text' => 'test' }
      dummy.extract_markup_params(params).should == [nil, { recursive: true }]
    end

    it "extracts the id_as param" do
      params = { 'id_as' => 'id' }
      dummy.extract_markup_params(params).should == [nil, { id_as: 'id'} ]
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
      dummy.to_xml([el1, el2]).should =~ /<a><b>/
    end

    it "includes the xml declaration" do
      el1 = double
      el1.stub(to_xml: '<a>')
      dummy.to_xml([el1]).should =~ /<\?xml version="1\.0" encoding="UTF-8"\?>/
    end

    it "looks for an optional param 'root', which is used to wrap the xml stream" do
      el1 = double
      el1.stub(to_xml: '<a>')
      res = /<body cite="128">.*<\/body>/
      dummy.to_xml([el1], { root: 'body cite="128"'}).should =~ res
    end

    it "its root element defaults to doc" do
      el1 = double
      el1.stub(to_xml: '<a>')
      dummy.to_xml([el1]).should =~ /<doc>.*<\/doc>/
    end
  end

  describe "#typecast_params!" do
    it "does typecasting for boolean strings" do
      params = { a: 1, b: 'true' }
      dummy.typecast_params!(params).should == { a: 1, b: true }
    end

    it "looks into Arrays as well" do
      params = { a: 'true', b: ['nil', 'false'] }
      dummy.typecast_params!(params).should == { a: true, b: [nil, false] }
    end
  end
end
