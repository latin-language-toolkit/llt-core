module LLT
  module Core::Structures::HashContainable
    # This class includes HashContainable and should be used as a simplistic
    # container with a stable tag and mostly without any attributes.
    # The id serves as tag.
    #
    # Thinking of xml this could look like this:
    # <files>
    #   # the contents of the containable
    # </files>
    class Generic
      include Core::Structures::HashContainable

      def xml_tag
        @id
      end

      def xml_attributes
        {}
      end
    end
  end
end
