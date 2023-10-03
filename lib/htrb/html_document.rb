module Htrb
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
      raise ArgumentError.new 'No block given' unless block_given?

      title_str = @title
      @head.contents do
        title do
          t title_str
        end
        meta charset: 'UTF-8'
        self.instance_eval &new_contents
      end

      self
    end

    def body(&new_contents)
      @body.contents &new_contents
    end

    def to_s
      @dom.to_s
    end

    def to_pretty
      @dom.to_pretty
    end
  end
end
