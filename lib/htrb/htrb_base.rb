module Htrb
  def self.fragment(&block)
    HtmlNode.new &block
  end

  def self.document
    HtmlDocument.new
  end
end
