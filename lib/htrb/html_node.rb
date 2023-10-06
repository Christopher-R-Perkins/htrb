require 'cgi'

module HTRB
  class HtmlNode
    def initialize(**attributes, &contents)
      raise SelfClosingTagError if self_closing? && block_given?
      @attributes = attributes
      @children = []
      render &contents
    end

    attr_reader :parent

    def inner_html(&new_contents)
      if block_given?
        @children.each { |child| child.parent = nil if child.is_a? HtmlNode }
        @children.clear
        render &new_contents
      end

      @children.dup
    end

    def append(child)
      unless child.is_a?(String) || child.is_a?(HtmlNode)
        raise ArgumentError.new 'A child must be a string or HtmlNode'
      end

      raise TagParadoxError.new if has_ancestor? child
      raise SelfClosingTagError.new if self_closing? && self.is_a?(Element)

      child.parent = self if child.is_a? HtmlNode
      @children.push child

      child
    end

    def insert(child, where, at)
      unless child.is_a?(String) || child.is_a?(HtmlNode)
        raise ArgumentError.new 'A child must be a string or HtmlNode'
      end

      index = @children.index at
      raise ArgumentError.new 'at is not in children' unless index
      raise TagParadoxError.new if has_ancestor? child

      case where
      when :before
        child.parent = self if child.is_a? HtmlNode
        @children.insert index, child
      when :after
        child.parent = self if child.is_a? HtmlNode
        @children.insert index + 1, child
      else
        raise ArgumentError.new 'Invalid where, must be :before or :after'
      end

      child
    end

    def remove(child)
      length = @children.length
      @children = @children.select { |c| c != child }

      if length > @children.length
        child.parent = nil if child.is_a? HtmlNode
        return child
      end

      nil
    end

    def to_s
      html = ''

      html += "<#{tag}#{attributes}>" if tag

      @children.each { |child| html += child.to_s }

      html += "</#{tag}>" if tag && !self_closing?

      html
    end

    def to_pretty
      self.to_pretty_arr.join("\n")
    end

    private

    def render(&contents)
      remit &contents if block_given?
    end

    def method_missing(symbol, *args)
      return nil if [:self_closing?, :tag].include? symbol
      super
    end

    def attributes
      attr_str = ''

      @attributes.each do |key, value|
        new_key = key.to_s.downcase.gsub /_/, '-'
        attr_str += " #{new_key}=\"#{value}\""
      end

      attr_str
    end

    def props
      @attributes
    end

    def remit(&contents)
      raise SelfClosingTagError.new if self_closing?

      raise ArgumentError.new 'Must pass block' unless block_given?

      instance_exec &contents
    end

    def t!(text)
      append CGI.escape_html(text.to_s)
    end

    def has_ancestor?(node)
      element = self
      until element == nil
        return true if element == node
        element = element.parent
      end

      false
    end

    protected

    def parent=(value)
      @parent.remove(self) if @parent
      @parent = value
    end

    TAB = '  '

    private_constant :TAB

    def to_pretty_arr(depth=0)
      depth -= 1 unless tag

      arr = []
      arr.push "#{TAB * depth}<#{tag}#{attributes}>" if tag
      @children.each do |child|
        if child.is_a? String
          arr.push "#{TAB * (depth + 1)}#{child}"
        else
          arr.push child.to_pretty_arr(depth + 1)
        end
      end

      arr.push "#{TAB * depth}</#{tag}>" if tag && !self_closing?
      arr
    end
  end

  private_constant :HtmlNode

  class TagExistsError < StandardError
    def initialize(symbol)
      super "Can't add component, the method `#{symbol}` already exists"
    end
  end

  class SelfClosingTagError < StandardError
    def initialize
      super "Can't add children to self closing tag"
    end
  end

  class TagParadoxError < StandardError
    def initialize
      super "Can't add a child as a descendant of itself"
    end
  end
end
