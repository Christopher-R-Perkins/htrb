module Htrb
  require_relative './html_node'

  def self.fragment(&block)
    Htrb::HtmlNode.new &block
  end

  def self.document
    Htrb::HtmlDocument.new
  end
end
