module HTRB
  class HtmlDocument
    def initialize
      @dom = HtmlNode.new
      @title = ''
      @head = Elements::Head.new
      @body = Elements::Body.new
      html = Elements::Html.new

      @dom.child '<!DOCTYPE html>'
      @dom.child html
      html.child @head
      html.child @body

      head do end
    end

    def head(&new_contents)
      title_str = @title

      @head.inner_html do
        title do
          t title_str
        end
        meta charset: 'UTF-8'
        self.instance_eval &new_contents
      end
    end

    def body(&new_contents)
      @body.inner_html &new_contents
    end

    def to_s
      @dom.to_s
    end

    def to_pretty
      @dom.to_pretty
    end
  end
end
