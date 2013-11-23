module LLT
  module Core
    module Containable
      include Enumerable

      attr_reader :container

      def initialize(string)
        @string = string
        @container = []
      end

      def <<(obj)
        @container << obj
        @container.flatten!
      end

      def to_s
        @string
      end

      def to_xml(tag = xml_tag)
        wrap_with_xml(tag, @string)
      end

      # @return [string] the default xml tag defined for the instances class
      def xml_tag
        self.class.default_xml_tag
      end

      def each(&blk)
        @container.each(&blk)
      end

      def all?(&blk)
        @container.empty? ? false : super
      end

      def include? x
        @container.include? x
      end

      def empty?
        @container.empty?
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      private

      def wrap_with_xml(tag, string)
        "<#{tag}>#{string}</#{tag}>"
      end

      module ClassMethods
        def container_alias(al)
          alias_method al, :container
          alias_method "no_#{al}?", :empty?
        end

        # Defines the default xml tag used by #to_xml
        def xml_tag(tag)
          @default_xml_tag = tag
        end

        def default_xml_tag
          @default_xml_tag
        end
      end
    end
  end
end
