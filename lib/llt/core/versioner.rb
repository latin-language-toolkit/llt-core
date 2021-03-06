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
        %{<service name="#{gem_name}" version="#{version}">} +
          %{<source href="#{source}"/>} +
        %{</service>}
      end

      private

      def namespace
        self.class.name.chomp('::VersionInfo')
      end
    end
  end
end
