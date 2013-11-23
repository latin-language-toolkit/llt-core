require 'spec_helper'

describe LLT::Core::Containable do
  let(:dummy) do
    Class.new do
      include LLT::Core::Containable
    end
  end

  let(:other_dummy) do
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

  describe "#as_xml" do
    it "represent the xml value that is used in #to_xml, defaults to the string it has been initialized with" do
      obj = dummy.new('test')
      obj.as_xml.should == 'test'
    end

    it "can be overwritten" do
      obj = dummy.new('test')
      obj.stub(:as_xml) { 'custom' }
      obj.as_xml.should == 'custom'
    end
  end

  describe "#to_xml" do
    it "returns the #as_xml value as xml with its default tag" do
      dummy.xml_tag 'test'
      obj = dummy.new('string')
      obj.to_xml.should == '<test>string</test>'
    end

    it "allows the tag to be given as param" do
      obj = dummy.new('string')
      obj.to_xml('tag').should == '<tag>string</tag>'
    end

    it "can be called recursively to include the container elements inside the default tag" do
      dummy.xml_tag 's'
      other_dummy.xml_tag 'w'

      sentence = dummy.new('a simple sentence')
      token1 = other_dummy.new('a')
      token2 = other_dummy.new('simple')
      token3 = other_dummy.new('sentence')
      sentence << [token1, token2, token3]
      result = '<s><w>a</w><w>simple</w><w>sentence</w></s>'
      sentence.to_xml(recursive: true).should == result
    end

    it "allows multiple tags given in an Array, which will be used recursively" do
      sentence = dummy.new('a simple sentence')
      token1 = dummy.new('a')
      token2 = dummy.new('simple')
      token3 = dummy.new('sentence')
      token1 << dummy.new('a')
      sentence << [token1, token2, token3]
      result = '<a><b><c>a</c></b><b>simple</b><b>sentence</b></a>'
      sentence.to_xml(%w{ a b c }, recursive: true).should == result
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
