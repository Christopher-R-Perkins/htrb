require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/htrb'

class HtrbTest < Minitest::Test
  def setup
    @empty_frag = HTRB.fragment

    tag = nil
    @container_frag = HTRB.fragment do
      tag = div id: 'container'
    end

    @div = tag
  end

  def test_html5_tags_are_methods
    HTRB::TAGS.each do |tag|
      assert_equal true, @empty_frag.respond_to?(tag, true)
    end
  end

  def test_fragment_is_node
    assert_equal 'HTRB::HtmlNode', @empty_frag.class.name
  end

  def test_fragment_to_s_empty
    assert_equal '', @empty_frag.to_s
  end

  def test_fragment_to_s
    assert_equal '<div id="container"></div>', @container_frag.to_s
  end

  def test_fragment_to_pretty_empty
    assert_equal '', @empty_frag.to_pretty
  end

  def test_fragment_to_pretty
    @div.append 'Hello'
    assert_equal "<div id=\"container\">\n  Hello\n</div>", @container_frag.to_pretty
  end

  def test_inner_html
    assert_equal [@div], @container_frag.inner_html
  end

  def test_inner_html_block
    @container_frag.inner_html {  }
    refute_equal [@div], @container_frag.inner_html
  end

  def test_fragment_append_node
    paragraph = HTRB::Elements::P.new
    return_value = @container_frag.append paragraph
    assert_equal paragraph, return_value
    assert_equal paragraph, @container_frag.inner_html[1]
  end

  def test_fragment_append_text
    text = 'Something'
    return_value = @container_frag.append text
    assert_equal text, return_value
    assert_equal text, @container_frag.inner_html[1]
  end

  def test_fragment_append_error
    bad_child = nil
    assert_raises(ArgumentError) { @empty_frag.append bad_child }
    assert_raises HTRB::SelfClosingTagError do
      HTRB::Elements::Hr.new.append @div
    end
  end

  def test_fragment_remove
    return_value = @container_frag.remove @div
    assert_equal @div, return_value
    assert_equal 0, @container_frag.inner_html.length

    return_value_empty = @container_frag.remove @div
    assert_nil return_value_empty
  end

  def test_fragment_insert_before
    image = HTRB::Elements::Img.new
    return_value = @container_frag.insert image, :before, @div
    assert_equal image, return_value
    assert_equal image, @container_frag.inner_html[0]
  end

  def test_fragment_insert_after
    text = 'after'
    return_value = @container_frag.insert text, :after, @div
    assert_equal text, return_value
    assert_equal text, @container_frag.inner_html[1]
  end

  def test_fragment_insert_errors
    assert_raises(ArgumentError) { @empty_frag.insert @div, :before, @div }
    assert_raises(ArgumentError) { @container_frag.insert @div, :never, @div }
    assert_raises(ArgumentError) { @container_frag.insert nil, :after, @div }

    link = @div.append HTRB::Elements::Link.new
    assert_raises HTRB::TagParadoxError do
      @div.insert @div, :before, link
    end
  end

  def test_self_closing_tag
    hr = HTRB::Elements::Hr.new
    assert_equal '<hr>', hr.to_s
  end

  def test_self_closing_tag_error
    assert_raises HTRB::SelfClosingTagError do
      HTRB::Elements::Track.new {}
    end
  end

  def test_attribute_key_replace_underscore
    br = HTRB::Elements::Br.new hx_post: '/clicked', 'hx_swap' => 'outerHTML'
    assert_equal '<br hx-post="/clicked" hx-swap="outerHTML">', br.to_s
  end

  def test_fragment_t
    em = HTRB::Elements::Em.new { t 'Testing text' }
    assert_equal '<em>Testing text</em>', em.to_s
  end

  def test_fragment_missing_method_error
    assert_raises(NameError) { @empty_frag.stupid }
  end

  def test_fragment_props
    button = HTRB::Elements::Button.new text: 'Button Text' do
      t props[:text]
    end
    assert_equal '<button text="Button Text">Button Text</button>', button.to_s
  end

  def test_component
    eval <<-CLASS_DEFINITION
      class Tester < HTRB::Component
        def render(**attributes, &block)
          t 'Test'
        end
      end
    CLASS_DEFINITION

    assert_equal true, @empty_frag.respond_to?(:_tester, true)
    assert_equal true, Tester.new.self_closing?

    @empty_frag.inner_html { _tester }
    assert_equal 'Test', @empty_frag.to_s
  end

  def test_component_duplicate_error
    assert_raises HTRB::TagExistsError do
      eval <<-CLASS_DEFINITION
        module One
          class Exists < HTRB::Component; end
        end

        module Another
          class Exists < HTRB::Component; end
        end
      CLASS_DEFINITION
    end
  end

  def test_html
    return_value = HTRB.html do
      div id: 'container' do
        img src: 'lol.jpg'
      end
    end

    assert_equal '<div id="container"><img src="lol.jpg"></div>', return_value
  end

  def test_document_is_document
    assert_kind_of HTRB::Document, HTRB.document
  end

  def test_document_to_pretty
    assert_equal "<!DOCTYPE html>\n<html>\n  <head>\n    <title>\n      \n    </title>\n    <meta charset=\"UTF-8\">\n  </head>\n  <body>\n  </body>\n</html>", HTRB.document.to_pretty
  end

  def test_document_to_s
    assert_equal '<!DOCTYPE html><html><head><title></title><meta charset="UTF-8"></head><body></body></html>', HTRB.document.to_s
  end

  def test_document_with_title
    doc = HTRB.document title: 'Has a title'
    assert_equal '<!DOCTYPE html><html><head><title>Has a title</title><meta charset="UTF-8"></head><body></body></html>', doc.to_s
  end

  def test_document_title_get
    doc = HTRB.document title: 'Has a title'
    assert_equal 'Has a title', doc.title
  end

  def test_document_title_set
    doc = HTRB.document
    old = HTRB.document.title
    doc.title 'Nice'

    refute_equal old, doc.title
    assert_equal 'Nice', doc.title
    assert_equal '<!DOCTYPE html><html><head><title>Nice</title><meta charset="UTF-8"></head><body></body></html>', doc.to_s
  end

  def test_document_pass_head
    head_proc = proc { link rel: 'stylesheet', href: 'mystyle.css' }
    doc = HTRB.document head: head_proc

    assert_equal '<!DOCTYPE html><html><head><title></title><meta charset="UTF-8"><link rel="stylesheet" href="mystyle.css"></head><body></body></html>', doc.to_s
  end

  def test_document_change_head
    doc = HTRB.document
    doc.head { link rel: 'stylesheet', href: 'mystyle.css' }

    assert_equal '<!DOCTYPE html><html><head><title></title><meta charset="UTF-8"><link rel="stylesheet" href="mystyle.css"></head><body></body></html>', doc.to_s
  end

  def test_document_pass_body
    doc = HTRB.document { t 'This is my body' }
    assert_equal '<!DOCTYPE html><html><head><title></title><meta charset="UTF-8"></head><body>This is my body</body></html>', doc.to_s
  end

  def test_document_change_body
    doc = HTRB.document
    doc.body { t 'This is my body' }
    assert_equal '<!DOCTYPE html><html><head><title></title><meta charset="UTF-8"></head><body>This is my body</body></html>', doc.to_s
  end
end
