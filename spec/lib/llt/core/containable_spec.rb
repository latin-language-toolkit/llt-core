require 'spec_helper'

describe LLT::Core::Containable do
  let(:dummy) do
    Class.new do
      include LLT::Core::Containable
    end
  end

  let(:instance) { dummy.new('') }

  describe "#to_s" do
    it "returns the string it has been initialized with" do
      obj = dummy.new('test')
      obj.to_s.should == 'test'
    end
  end

  describe "#to_xml" do
    it "returns the #to_s value as xml with its default tag" do
      dummy.xml_tag 'test'
      obj = dummy.new('string')
      obj.to_xml.should == '<test>string</test>'
    end

    it "allows the tag to be given as param" do
      obj = dummy.new('string')
      obj.to_xml('tag').should == '<tag>string</tag>'
    end
  end

  describe "#container" do
    it "returns the contents of the container" do
      instance.container.should == []
    end
  end

  describe "#<<" do
    it "adds an element to the container" do
      instance << 1
      instance.container.should == [1]
    end

    it "also takes an array, which is flattened" do
      instance << [1,2]
      instance.container.should == [1,2]
    end
  end

  describe "#each" do
    it "redirects Enumerable methods to the container" do
      instance << [1,2]
      instance.inject(:+).should == 3
    end
  end

  describe "#all?" do
    it "changes implementation of all, which returns false when empty!" do
      instance.container.should be_empty
      instance.all?.should be_false
    end
  end

  describe "#include?" do
    it "redirects to the container" do
      instance << 1
      instance.include?(1).should be_true
    end
  end

  describe "#empty?" do
    it "redirects to the container" do
      instance << 1
      instance.should_not be_empty
    end
  end

  describe ".container_alias" do
    it "sets an alias to access the container for more idiomaticity" do
      dummy.container_alias :tokens
      sentence = instance
      sentence << [:token, :token]
      sentence.tokens.should == sentence.container
    end
  end

  describe ".xml_tag" do
    it "sets the classes default xml tag" do
      dummy.xml_tag('s')
      instance.xml_tag.should == 's'
    end
  end
end
