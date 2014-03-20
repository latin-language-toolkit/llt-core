require 'cgi'
require 'open-uri'
require 'xml_escape'

module LLT
  module Core
    module Api
      module Helpers
        include XmlEscape

        # tries to resolve an uri or a text included in the params
        #
        # strips any incoming xml declaration because it gets added back in at
        # the end and otherwise will be duped
        # if an xml declaration is included, the xml param is set to true
        def extract_text(params)
          text = get_text(params)
          if has_xml_declaration?(text)
            params[:xml] = true
            text.sub(XML_DECLARATION_REGEXP, '')
          else
            text
          end
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

        XML_DECLARATION_REGEXP = /<\?xml.*?\?>/
        XML_DECLARATION = %{<?xml version="1.0" encoding="UTF-8"?>}

        def has_xml_declaration?(txt)
          txt.match(XML_DECLARATION_REGEXP)
        end

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

        def get_from_uri(uri)
          URI(uri).read
        end
      end
    end
  end
end
