module LLT
  module Core
    module Containable
      include Enumerable

      attr_reader :container, :id
      alias_method :n, :id

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

      def to_xml(tags = nil, indexing: false,
                             recursive: false,
                             inline: false,
                             attrs: {})

        # for easier recursion it's solved in a way that might
        # look awkward on first sight
        tags = Array(tags)
        tag = tags.shift || default_xml_tag
        end_of_recursion = false

        val = if recursive && all? { |e| e.respond_to?(:to_xml)}
                attrs.merge!(inline_id(tag)) if inline && indexing
                recursive_xml(tags, indexing, inline, attrs)
              else
                end_of_recursion = true
                as_xml
              end

        if inline
          end_of_recursion ? wrap_with_xml(tag, val, indexing, attrs) : val
        else
          wrap_with_xml(tag, val, indexing, attrs)
        end
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

      # id is represented as @n attribute in the xml, as xml:id
      # is reserved for something else
      def wrap_with_xml(tag, string, indexing, attrs = {})
        merge_id!(attrs) if indexing && @id
        attr = attrs.any? ? " #{to_xml_attrs(attrs)}" : ''
        "<#{tag}#{attr}>#{string}</#{tag}>"
      end

      def to_xml_attrs(attrs)
        attrs.map { |k, v| %{#{k}="#{v}"} }.join(' ')
      end

      def recursive_xml(tags, indexing, inline, attrs)
        map do |element|
          element.to_xml(tags.clone, indexing: indexing, recursive: true,
                                     inline: inline, attrs: attrs)
        end.join
      end

      def merge_id!(attrs)
        attrs.merge!(id_as_xml => @id,)
      end

      def id_as_xml
        'n'
      end

      def inline_id(tag)
        { "#{tag}_#{id_as_xml}" => @id }
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
