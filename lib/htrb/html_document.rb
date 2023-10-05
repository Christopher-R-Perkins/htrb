module HTRB
  class Document
    def initialize **options, &body_content
      @dom = HtmlNode.new
      @title = options[:title] || ''
      @head = Elements::Head.new
      @body = Elements::Body.new &body_content
      html = Elements::Html.new

      @dom.append '<!DOCTYPE html>'
      @dom.append html
      html.append @head
      html.append @body

      head &options[:head]
    end

    def head(&new_contents)
      title_str = @title

      @head.inner_html do
        title do
          t title_str
        end
        meta charset: 'UTF-8'
        remit &new_contents if block_given?
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

    def title(new_title=nil)
      @title.replace new_title.to_s if new_title
      @title
    end
  end
end
