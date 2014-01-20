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

        # tries to resolve an uri or a text included in the params
        def extract_text(params)
          text = get_text(params)
          # strip the xml declaration because it gets added back in at the
          # end and otherwise will be duped
          text.sub(XML_DECLARATION, '')
        end

        def extract_markup_params(params)
          mu_params = %i{ recursive indexing inline id_as }
          extracted = [params[:tags]]
          relevant = mu_params.each_with_object({}) do |param, h|
            val = params[param]
            val = params[param.to_s] if val.nil?
            h[param] = val unless val.nil?
          end
          extracted << relevant
        end

        def to_xml(elements, params = {})
          root = params[:root] || 'doc'
          root_close = root.match(/^\w+/)[0]
          tags, options = *extract_markup_params(params)
          body = elements.each_with_object('') do |e, str|
            # need to clone, otherwise the tags will get eaten
            # up in the markup method, but we cannot if tags
            # is nil
            cloned_tags = (tags ? tags.clone : tags)
            # Options need to be cloned as well! Time for another
            # jruby issue: The keywords seem to be eaten up somewhere
            # along the road. Need to investigate further.
            str << e.to_xml(cloned_tags, options.clone)
          end
          "#{XML_DECLARATION}<#{root}>#{body}</#{root_close}>"
        end

        def typecast_params!(params)
          params.each do |k, v|
            params[k] = typecast(v)
          end
        end

        private

        XML_DECLARATION = %{<?xml version="1.0" encoding="UTF-8"?>}

        def get_text(params)
          if uri = params[:uri]
            get_from_uri(uri)
          else
            params[:text]
          end
        end

        def typecast(val)
          if val.kind_of?(Array)
            val.map { |e| typecast(e) }
          else
            case val
            when 'true'  then true
            when 'false' then false
            when 'nil'   then nil
            else val
            end
          end
        end

        # Net::Http.get is broken in jruby when running in
        # 2.0 mode - we need to use some different when going
        # the java route.
        if RUBY_PLATFORM == 'java'
          require 'http_client'
          HTTP_CLIENT = HTTP::Client.new

          def get_from_uri(uri)
            HTTP_CLIENT.get(uri)
          end
        else
          require 'open-uri'

          def get_from_uri(uri)
            URI(uri).read
          end
        end
      end
    end
  end
end
