require 'cgi'
require 'net/http'

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

        # tries to resolve an uri or a text included in the params
        def extract_text(params)
          if uri = params[:uri]
            Net::HTTP.get(URI(uu(uri)))
          else
            params[:text]
          end
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

        def typecast_params!(params)
          params.each do |k, v|
            params[k] = typecast(v)
          end
        end

        private

        def typecast(val)
          case val
          when 'true'  then true
          when 'false' then false
          else val
          end
        end
      end
    end
  end
end
