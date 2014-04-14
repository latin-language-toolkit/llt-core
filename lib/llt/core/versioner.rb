module LLT
  module Core
    module Versioner
      LLT_GH_PATH = 'https://github.com/latin-language-toolkit'

      def gem_name
        namespace.sub('::', '-').downcase
      end

      def source
        "#{LLT_GH_PATH}/#{gem_name}"
      end

      def version
        self.class.const_get("#{namespace}::VERSION")
      end

      def to_xml
        %{<gem name="#{gem_name}" version="#{version}">} +
          %{<source href="#{source}"/>} +
        %{</gem>}
      end

      private

      def namespace
        self.class.name.chomp('::Version')
      end
    end
  end
end
