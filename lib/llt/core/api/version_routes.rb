module LLT
  module Core::Api::VersionRoutes
    def add_version_route_for(route, params)
      dependencies = params[:dependencies]

      get("#{route}/version") do
        output = dependencies.map do |dep_class|
          versioner = LLT.const_get(dep_class).const_get(:VersionInfo).new
          versioner.to_xml
        end.join

        respond_to do |f|
          f.xml { output }
        end
      end
    end
  end
end
