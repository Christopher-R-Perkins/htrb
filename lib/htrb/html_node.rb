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
        @children.push subclass.new(**attributes, &contents)

        @children.last
      end
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

    def t(text)
      unless text.class == String
        raise ArgumentError.new 'Text nodes can only be passed strings'
      end

      @children.push text
      text
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
  end

  class TagExistsError < StandardError
    def initialize(symbol)
      super("htrb component `#{symbol}` already exists")
    end
  end
end
