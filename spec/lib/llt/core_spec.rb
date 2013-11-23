require 'spec_helper'

describe LLT::Core do
  it 'should have a version number' do
    LLT::Core::VERSION.should_not be_nil
  end
end
