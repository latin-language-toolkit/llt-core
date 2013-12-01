require 'cgi'

module LLT
  module Core
    module Api
      module Helpers
        def uu(text)
          CGI.unescape(text)
        end

        def u(text)
          CGI.escape(text)
        end

        def extract_markup_params(params)
          mu_params = %i{ recursive indexing inline }
          extracted = [params[:tags]]
          relevant = mu_params.each_with_object({}) do |param, h|
            val = params[param]
            val = params[param.to_s] if val.nil?
            h[param] = val unless val.nil?
          end
          extracted << relevant if relevant.any?
          extracted.compact
        end

        def to_xml(elements, params = {})
          elements.each_with_object('') do |e, str|
            str << e.to_xml(*extract_markup_params(params))
          end
        end
      end
    end
  end
end
