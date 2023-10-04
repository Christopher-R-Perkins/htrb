module HTRB
  def self.fragment(&content)
    HtmlNode.new &content
  end

  def self.document
    HtmlDocument.new
  end

  def self.html(&content)
    throw ArgumentError.new "No block passed" unless block_given?

    HtmlNode.new(&content).to_s
  end
end
