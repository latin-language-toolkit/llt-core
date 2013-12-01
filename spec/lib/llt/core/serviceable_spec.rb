require 'spec_helper'

describe LLT::Core::Serviceable do
  let(:dummy) do
    Class.new do
      include LLT::Core::Serviceable
      attr_reader :a_service

      def service_class
        nil
      end

      def service_name
        :dummy_service
      end

      def self.default_options
        {
          option1: false,
          option2: true
        }
      end
    end
  end

  let(:service_class) { double }

  it "provides readers for used services" do
    dummy.uses_a_service { 1 }
    instance = dummy.new
    instance.should respond_to(:a_service)
  end

  it "provides writers for used services" do
    dummy.uses_a_service { 1 }

    instance = dummy.new
    instance.a_service.should == 1

    instance.a_service = 2
    instance.a_service.should == 2
  end

  it "provides a reader for the instance's default options" do
    instance = dummy.new
    instance.default_options.should == { option1: false, option2: true }
  end

  describe ".uses_***" do
    it "provides including classes with the dynamic method .uses_***" do
      dummy.should respond_to(:uses_a_service)
      dummy.should respond_to(:uses_another_service)
    end
  end

  describe ".used_services" do
    it "returns service used by the Serviceable including class" do
      dummy.uses_a_service { 1 }
      dummy.used_services.should have(1).item
      dummy.used_services[:a_service].call.should == 1
    end
  end

  describe "#initialize" do
    context "when the class is using a service" do
      context "with options" do
        it "sets service as given" do
          dummy.uses_a_service { 2 }
          instance = dummy.new(a_service: 1)
          instance.a_service.should == 1
        end
      end

      context "without options" do
        # service class is usually LLT::Service or nothing
        it "tries to obtain a service registered in the service class" do
          service_class.stub(:fetch) { :registered_service }
          service_class.stub(:registered?) { true }
          dummy.any_instance.stub(:service_class) { service_class }

          dummy.uses_a_service { 1 }
          instance = dummy.new
          instance.a_service.should == :registered_service
        end

        it "initializes with its default service when service class doesn't have anything" do
          service_class.stub(:fetch) { nil }
          service_class.stub(:registered?) { true }
          dummy.any_instance.stub(:service_class) { service_class }

          dummy.uses_a_service { 1 }
          instance = dummy.new
          instance.a_service.should == 1
        end
      end

      it "tries to register itself in the service class" do
        service_class.stub(:registered?) { false }
        dummy.any_instance.stub(:service_class) { service_class }

        service_class.should receive(:register).with(dummy_service: an_instance_of(dummy))

        dummy.new
      end

      it "fails to register when such a service is already registered" do
        service_class.stub(:registered?) { true }
        dummy.any_instance.stub(:service_class) { service_class }

        service_class.should_not receive(:register)

        dummy.new
      end
    end

    context "when the class is not using a service" do
      it "doesn't instantiate a given service" do
        dummy.uses_another_service { 2 }
        instance = dummy.new(a_service: 1)
        instance.a_service.should be_nil
      end
    end

    context "with default options passed in" do
      it "sets them only if they appear in Class.default_options" do
        instance = dummy.new(option3: 3)
        instance.default_options.should == { option1: false, option2: true }
      end

      it "strings as keys are valid as well", :focus do
        instance = dummy.new('option1' => 1)
        instance.default_options.should == { option1: 1, option2: true }
      end

      it "services are not saved as default options" do
        dummy.uses_a_service { 1 }
        instance = dummy.new(a_service: 2)
        instance.a_service.should == 2
        instance.default_options.should == { option1: false, option2: true }
      end
    end
  end

  describe "#register!" do
    it "registers self in the service class (if it's available), even if such a service is present" do
      service_class.stub(:registered?) { true }
      dummy.any_instance.stub(:service_class) { service_class }

      service = dummy.new

      service_class.should receive(:register).once
      service.register!
    end
  end

  describe "#fork_instance" do
    it "returns a new service instance with the same default options as self" do
      instance = dummy.new(option1: 1, option2: 2)
      forked = instance.fork_instance
      forked.should_not == instance
      forked.default_options.should == instance.default_options
    end
  end

  context "private unit tests" do
    describe "#parse_option" do
      context "parses a given option from a given options hash in the light of the default options" do
        it "retains legitimate false values" do
          instance = dummy.new
          # just repeating here for clarification
          instance.default_options.should == { option1: false, option2: true }

          option = instance.send(:parse_option, :option1, { option3: 3 })
          option.should == false
        end

        it "works with Symbols and Strings as keys in the options hash" do
          instance = dummy.new
          option = instance.send(:parse_option, :option2, { 'option2' => false })
          option.should == false
        end
      end
    end
  end
end
