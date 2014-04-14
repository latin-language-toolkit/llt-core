require 'llt/core/versioner'

module LLT
  module Core
    VERSION = "0.0.2"

    class Version
      include Core::Versioner
    end
  end
end
