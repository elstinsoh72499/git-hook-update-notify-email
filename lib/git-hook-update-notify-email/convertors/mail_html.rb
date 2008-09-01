require 'syntax/convertors/abstract'

module Syntax
  module Convertors

    # A simple class for converting a text into HTML.
    class MailHTML < Abstract

      # Converts the given text to HTML, using spans to represent token groups
      # of any type but <tt>:normal</tt> (which is always unhighlighted). If
      # +pre+ is +true+, the html is automatically wrapped in pre tags.
      def convert( text, style, pre=true )
        @style = style
        html = ""
        html << "<pre>" if pre
        regions = []
        @tokenizer.tokenize( text ) do |tok|
          value = html_escape(tok)
          case tok.instruction
            when :region_close then
              regions.pop
              html << "</span>"
            when :region_open then
              regions.push tok.group
              html << "<span style=\"#{style(tok.group)}\">#{value}"
            else
              if tok.group == ( regions.last || :normal )
                html << value
              else
                html << "<span style=\"#{style(tok.group)}\">#{value}</span>"
              end
          end
        end
        html << "</span>" while regions.pop
        html << "</pre>" if pre
        html
      end

      private

        # Replaces some characters with their corresponding HTML entities.
        def html_escape( string )
          string.gsub( /&/, "&amp;" ).
                 gsub( /</, "&lt;" ).
                 gsub( />/, "&gt;" ).
                 gsub( /"/, "&quot;" )
        end

        def style(group)
          if @style.key? group
            @style[group]
          else
            ""
          end
        end
    end
  end
end
