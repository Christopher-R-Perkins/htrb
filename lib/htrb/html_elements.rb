module HTRB
  class Element < HtmlNode
    def self.inherited(subclass)
      sym = subclass.name.downcase.split('::').last.to_sym

      raise TagExistsError.new sym if HtmlNode.method_defined? sym

      HtmlNode.send :define_method, sym do |**attributes, &contents|
        child subclass.new(**attributes, &contents)
      end
    end
  end

  TAGS = [
    :a, :abbr, :address, :area, :article, :aside, :audio, :b, :bdi, :bdo,
    :blockquote, :body, :br, :button, :canvas, :caption, :cite, :code, :col,
    :colgroup, :command, :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt,
    :em, :embed, :fieldset, :figcaption, :figure, :footer, :form, :h1, :h2,
    :h3, :h4, :h5, :h6, :head, :header, :hr, :html, :i, :iframe, :img, :input,
    :ins, :kbd, :keygen, :label, :legend, :li, :main, :map, :mark, :menu, :meta,
    :meter, :nav, :object, :ol, :optgroup, :option, :output, :p, :param, :pre,
    :progress, :q, :rp, :rt, :ruby, :s, :samp, :section, :select, :small,
    :script, :source, :span, :strong, :sub, :summary, :sup, :table, :tbody, :td,
    :textarea, :tfoot, :th, :thead, :time, :title, :tr, :track, :u, :ul, :var,
    :video, :wbr,
  ]

  SELF_CLOSING = [
    :area, :base, :br, :col, :embed, :hr, :img, :input, :keygen, :link, :meta, :param, :source, :track, :wbr,
  ]

  TAGS.each do |tag|
    self_closing = SELF_CLOSING.include? tag
    tag_name = tag.to_s

    eval <<-CLASS_DEFINITION
      module Elements
        class #{tag_name.capitalize} < Element
          def tag
            '#{tag_name}'
          end

          def self_closing?
            #{self_closing}
          end
        end
      end
    CLASS_DEFINITION
  end
end
