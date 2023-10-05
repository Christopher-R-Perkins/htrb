module HTRB
  class Element < HtmlNode
    def self.inherited(subclass)
      sym = subclass.name.downcase.split('::').last.to_sym

      HtmlNode.send :define_method, sym do |**attributes, &contents|
        append subclass.new(**attributes, &contents)
      end
      HtmlNode.send :private, sym
    end
  end

  private_constant :Element

  TAGS = [
    :a, :abbr, :address, :area, :article, :aside, :audio, :b, :base, :bdi,
    :bdo, :blockquote, :body, :br, :button, :canvas, :caption, :cite, :code,
    :col, :colgroup, :data, :datalist, :dd, :del, :details, :dfn, :dialog,
    :div, :dl, :dt, :em, :embed, :fieldset, :figcaption, :figure, :footer,
    :form, :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hgroup, :hr, :html,
    :i, :iframe, :img, :input, :ins, :kbd, :keygen, :label, :legend, :li,
    :link, :main, :map,  :mark, :math, :menu, :meta, :meter, :nav, :noscript,
    :object,  :ol, :optgroup, :option, :output, :p, :picture, :portal, :pre,
    :progress, :q, :rp, :rt, :ruby, :s, :samp, :script, :search, :section,
    :select, :slot, :small, :source, :span, :strong, :style, :sub, :summary,
    :sup, :svg, :table, :tbody, :td, :template, :textarea, :tfoot, :th,
    :thead, :time, :title, :tr, :track, :u, :ul, :var, :video, :wbr,
  ]

  SELF_CLOSING = [
    :area, :base, :br, :col, :embed, :hr, :img, :input, :keygen, :link, :meta,
    :source, :track, :wbr,
  ]

  TAGS.each do |tag|
    self_closing = SELF_CLOSING.include? tag
    tag_name = tag.to_s
    class_name = tag_name.capitalize

    eval <<-CLASS_DEFINITION
      module Elements
        class #{class_name} < Element
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
