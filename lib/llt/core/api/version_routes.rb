module LLT
  module Core::Api::VersionRoutes
    def add_version_route_for(route, params)
      dependencies = params[:dependencies]

      get("#{route}/version") do
        dependencies.map do |dep_class|
          versioner = LLT.const_get(dep_class).const_get(:Version).new
          versioner.to_xml
        end.join
      end
    end
  end
end
