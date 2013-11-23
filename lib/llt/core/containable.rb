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

      def to_xml(tags = nil, recursive: false, indent: 2)
        # for easier recursion it's solved in a way that might
        # look awkward on first sight
        tags = Array(tags)
        tag = tags.shift || xml_tag

        val = recursive && all? { |e| e.respond_to?(:to_xml)} ?
          recursive_xml(tags, indent) : @string
        wrap_with_xml(tag, indent, val)
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

      def wrap_with_xml(tag, indent, string)
        ind = to_ws(indent)
        "<#{tag}>\n#{ind}#{string}\n#{ind[0..-3]}</#{tag}>"
      end

      def recursive_xml(tags, indent)
        ind = indent + 2
        map do |element|
          element.to_xml(tags.clone, recursive: true, indent: ind)
        end.join("\n#{to_ws(indent)}")
      end

      def to_ws(i)
        # ugly but faster
        str = ''
        i.times { str << ' '}
        str
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
