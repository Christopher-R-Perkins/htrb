module HTRB
  class HtmlNode
    def initialize(**attributes, &contents)
      @attributes = attributes
      @children = []
      render &contents
    end

    attr_reader :parent

    def inner_html(&new_contents)
      if block_given?
        @children.clear
        render &new_contents
      end

      @children.dup
    end

    def append(child)
      unless child.is_a?(String) || child.is_a?(HtmlNode)
        raise ArgumentError.new 'A child must be a string or HtmlNode'
      end

      @children.push child
      child.parent = self if child.is_a? HtmlNode

      child
    end

    def insert(child, where, at)
      unless child.is_a?(String) || child.is_a?(HtmlNode)
        raise ArgumentError.new 'A child must be a string or HtmlNode'
      end

      index = @children.index at
      raise ArgumentError.new 'at is not in children' unless index

      case where
      when :before
        @children.insert index, child
      when :after
        @children.insert index + 1, child
      else
        raise ArgumentError.new 'Invalid where, must be :before or :after'
      end

      child.parent = self if child.is_a? HtmlNode
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

    def t(text)
      append text.to_s
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
      if self_closing?
        raise SelfClosingTagError.new
      end

      raise ArgumentError.new 'Must pass block' unless block_given?

      instance_eval &contents
    end

    protected

    attr_writer :parent

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

      arr.push "#{TAB * depth}</#{tag}>" if tag
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
end
