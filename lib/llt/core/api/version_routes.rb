require 'llt/core/api/helpers'

module LLT
  module Core::Api
    module VersionRoutes
      def add_version_route_for(route, params)
        dependencies = params[:dependencies]

        get("#{route}/version") do
          services = dependencies.map do |dep_class|
            versioner = LLT.const_get(dep_class).const_get(:VersionInfo).new
            versioner.to_xml
          end.join

          output = "#{Helpers::XML_DECLARATION}<services>#{services}</services>"

          respond_to do |f|
            f.xml { output }
          end
        end
      end
    end
  end
end
