module Htrb
  class HtmlNode
    def initialize(**attributes, &contents)
      @attributes = attributes
      @children = []
      render &contents
    end

    def self.inherited(subclass)
      sym = subclass.name.downcase.split('::').last.to_sym

      raise TagExistsError.new sym if method_defined? sym

      self.define_method sym do |**attributes, &contents|
        child subclass.new(**attributes, &contents)
      end
    end

    def contents(&contents)
      if block_given?
        @children.clear
        render &contents
      end

      @children.dup
    end

    def child(child)
      unless child.is_a?(String) || child.is_a?(Htrb::HtmlNode)
        raise ArgumentError.new 'A child must be a string or HtmlNode'
      end

      if self_closing?
        raise SelfClosingTagError.new
      end

      @children.push child

      child
    end

    def t(text)
      child text
    end

    def to_s
      html = ''

      html += "<#{tag}#{attributes}>" if tag

      unless self_closing?
        @children.each { |child| html += child.to_s }

        html += "</#{tag}>" if tag
      end

      html
    end

    def to_pretty
      self.to_pretty_arr.join("\n")
    end

    private

    def render(&contents)
      instance_eval &contents if block_given? && !self_closing?
    end

    def method_missing(symbol, *args)
      return false if [:self_closing?, :tag].include? symbol
      super
    end

    def attributes
      attr_str = ''

      @attributes.each do |key, value|
        attr_str += " #{key}=\"#{value}\""
      end

      attr_str
    end

    def props
      @attributes
    end

    protected

    TAB = '  '

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

      arr.push "#{TAB * depth}</#{tag}>" if tag
      arr
    end
  end

  class TagExistsError < StandardError
    def initialize(symbol)
      super "htrb component `#{symbol}` already exists"
    end
  end

  class SelfClosingTagError < StandardError
    def initialize
      super "Can't add children to self closing tag"
    end
  end
end
