module HTRB
  class Document
    def initialize
      @dom = HtmlNode.new
      @title = ''
      @head = Head.new
      @body = Body.new
      html = Html.new

      @dom.append_child '<!DOCTYPE html>'
      @dom.append_child html
      html.append_child @head
      html.append_child @body

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
