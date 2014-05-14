module LLT
  module Core::Structures
    module HashContainable
      include Enumerable

      attr_reader :container, :id

      def initialize(id = nil)
        @id = id
        @container = {}
      end

      def to_s
        @container.values.map { |val| val.to_s }.join(' ')
      end

      def add(element)
        @container[element.id] = element
      end

      def each(&blk)
        @container.each(&blk)
      end

      def each_value
        @container.each { |_, el| yield(el) }
      end

      def empty?
        @container.empty?
      end

      def [](id)
        @container[id]
      end

      def []=(id, element)
        @container[id] = element
      end

      def take(*ids)
        @container.values_at(*ids)
      end

      def size
        @container.size
      end

      def xml_attributes
        { id: id }
      end

      def xml_heading
        %{<#{xml_tag} id="#{id}"/>}
      end

      def xml_tag
        self.class.default_xml_tag
      end
      alias_method :default_xml_tag, :xml_tag

      def to_xml
        "<#{xml_tag}#{to_xml_attrs(xml_attributes)}>" +
          container_to_xml + additional_xml_content +
        "</#{xml_tag}>"
      end

      def container_to_xml
        "#{container.values.map(&:to_xml).join}"
      end

      def additional_xml_content
        ''
      end

      def replace_with_clone(*inst_vars)
        inst_vars.each do |iv|
          ivn = "@#{iv}"
          cloned = hash_with_cloned_values(instance_variable_get(ivn))
          instance_variable_set(ivn, cloned)
        end
      end

      private

      # explicitly ask for nil, we might want true and false values,
      # while nil basically means 'undefined'
      def to_xml_attrs(attrs)
        attrs.map { |k, v| %{ #{k}="#{v}"} unless v.nil? }.join
      end

      def counter_hash
        Hash.new(0)
      end

      def hash_with_cloned_values(hsh)
        Hash[hsh.map { |k, v| [k, v.clone] }]
      end

      def self.included(klass)
        klass.extend(ClassMethods)
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
