module LLT
  module Core
    module Containable
      include Enumerable

      attr_reader :container, :id

      def initialize(string, id = nil)
        @string = string
        @container = []
        @id        = id
      end

      def <<(obj)
        @container << obj
        @container.flatten!
      end

      def [](arg)
        @container[arg]
      end

      def to_s
        @string
      end

      def to_xml(tags = nil, indexing: false, recursive: false)
        # for easier recursion it's solved in a way that might
        # look awkward on first sight
        tags = Array(tags)
        tag = tags.shift || default_xml_tag

        val = recursive && all? { |e| e.respond_to?(:to_xml)} ?
          recursive_xml(tags, indexing) : as_xml
        wrap_with_xml(tag, val, indexing)
      end

      def as_xml
        @string
      end

      def as_json
        @string
      end

      # @return [string] the default xml tag defined for the instances class
      def xml_tag
        self.class.default_xml_tag
      end
      alias_method :default_xml_tag, :xml_tag

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

      def wrap_with_xml(tag, string, indexing, attrs = {})
        attrs.merge!(id: @id) if indexing && @id
        attr = attrs.any? ? " #{to_xml_attrs(attrs)}" : ''
        "<#{tag}#{attr}>#{string}</#{tag}>"
      end

      def to_xml_attrs(attrs)
        attrs.map { |k, v| %{#{k}="#{v}"} }.join(' ')
      end

      def recursive_xml(tags, indexing)
        map do |element|
          element.to_xml(tags.clone, indexing: indexing, recursive: true)
        end.join
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
