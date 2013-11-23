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

      module ClassMethods
        def container_alias(al)
          alias_method al, :container
          alias_method "no_#{al}?", :empty?
        end
      end
    end
  end
end
