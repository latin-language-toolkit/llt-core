require 'spec_helper'

describe LLT::Core::Containable do
  let(:dummy) do
    Class.new do
      include LLT::Core::Containable
    end
  end

  describe "#to_s" do
    it "returns the string it has been initialized with" do
      instance = dummy.new('test')
      instance.to_s.should == 'test'
    end
  end
end
