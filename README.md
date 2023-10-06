# HTRB - HTML DSL Gem

[![Gem Version](https://badge.fury.io/rb/htrb.svg)](https://badge.fury.io/rb/htrb)

**HTRB** is a DSL for creating dynamic HTML components with Ruby.

## Table of Contents
- [General Info](#general-info)
- [Use](#use)
  - [Installation](#installation)
  - [DSL](#dsl)
      - [Warning](#warning)
  - [HTRB#html](#htrbhtml)
  - [HTRB#fragment](#htrbfragment)
  - [HTRB#document](#htrbdocument)
- [Custom Components](#custom-components)
  - [Container Components](#container-components)
- [Reference](#reference)
  - [HTRB::HtmlNode](#htrbhtmlnode)
      - [HtmlNode#initialize](#htmlnodeinitialize)
      - [HtmlNode#parent](#htmlnodeparent)
      - [HtmlNode#append](#htmlnodeappend)
      - [HtmlNode#insert](#htmlnodeinsert)
      - [HtmlNode#remove](#htmlnoderemove)
      - [HtmlNode#to_s](#htmlnodeto_s)
      - [HtmlNode#to_pretty](#htmlnodeto_pretty)
  - [HTRB::Document](#htrbdocument)
      - [Document#initialize](#documentinitialize)
      - [Document#head](#documenthead)
      - [Document#body](#documentbody)
      - [Document#title](#documenttitle)
      - [Document#to_s](#documentto_s)
      - [Document#to_pretty](#documentto_pretty)


## General Info

**HTRB** allows you to write HTML inside your Ruby code through the use of a DSL. It was inspired by [JSX](https://react.dev/learn/writing-markup-with-jsx) and [Hypertext](https://github.com/soveran/hypertext).

**HTRB** allows you to seamlessly write HTML along with your Ruby code. In addition, it allows you to write your own dynamic custom HTML components which can be inserted in with regular HTML to make truly dynamic content.

It has been designed with technologies like [htmx](https://htmx.org/), [Alpine.js](https://alpinejs.dev/), and [Tailwind CSS](https://tailwindcss.com/) in mind to allow easy rendering of HTML fragments on the backend.

## Use
### Installation
**HTRB** require Ruby 3.0.0 or higher.

To use **HTRB**, first you need to install the gem:

```bash
gem install htrb
```

Then to use it in your own code, you need to `require` it:

```ruby
require 'htrb'
```

### DSL

In general, where applicable, **HTRB** provides methods that mimic html tags. Inside blocks related to HTML, you may call these methods to add the particular tag to the HTML as a child. Every non-depricated HTML5 tag is available in syntax like this:

```ruby
tag_name! **attributes, &contents-block
```

So the `<a>` tag would be represented by the method `a!`, while the `main` tag is represented by the method `main!`.

Attributes are comma separated name-value pairs and can be in either `name: value` or `"name" => value` forms. So `a! href='/'` would be the same as `<a href="/"></a>` and `img! src: '/a.png', 'alt' => 'The letter A'` would be the same as `<img src="/a.png' alt="The letter A">`. One thing to note is that **HTRB** will automatically change `_` characters in keys to `-` characters, that means `span hx_post: '/accounts'` would become `<span hx-post="/accounts"></span>`

Finally, you can optionally pass a block to every tag, though self-closing tags will raise an `HTRB::SelfClosingTagError` if you try to pass a block to them. These blocks allow you to add child elements to the element you are creating. For example the following will create the equivalent to `<a href="/join">Join in!</a>`:

```ruby
a! href: '/join' do
  t! 'Join in!'
end
```

Oh, did I just use `t!`, `<t>` isn't a tag. No, but `t!` is a special method created to make a text node. Its use is just `t! string` and it will make the string a child of the parent element. Do note, `t!` automatically escapes HTML, so if you don't want that use `append` instead(see [HTRB::HtmlNode](#htrbhtmlnode) reference)

#### Warning

Due to the nature of Ruby meta-programming in order to make the DSL work, the blocks are ran in the context of the `HtmlNode` it is being passed to. This means that instance variables and instance method calls will use the context of the object and not the scope the block was created in. Local variables are ok.

```ruby
@global = 'No'

HTRB.html do
  p @global # => nil, referencing HtmlNode instance

  @text = 'Some text'
  text = @text

  a! href: '/join' do
    t! text if text == @text
    # text = 'Some text' due to closure
    # @text = nil, it is referencing the A instance
  end
end # <a href="/join"></a>
```

So, if you plan on using instance variables in your project, it is best to assign what you need to local variables prior to referencing them in a block.

### HTRB#html

One of the most useful methods provided by **HTRB** is `html`. It allows you to quickly create a string containing the raw HTML you provide via the DSL inside a block.

```ruby
HTRB.html do
  p! id: 'some-text' do
    t! 'This is just some text inside a paragraph tag'
  end
  img! src: "/smiley.jpg"
end
# => '<p id="some-text">This is just some text inside a paragraph tag</p><img src="/smiley.jg">'
```

### HTRB#fragment

The `fragment` method is very similar to `HTRB#html`. In fact, the `html` does the same thing, except it calls `to_s` on the resulting object and returns the string.

`HTRB#fragment` creates an `HtmlNode` and populates its children with the block you pass to it. You are returned the resulting `HtmlNode` object and are free to do with it as you please. See [HTRB::HtmlNode](#htrbhtmlnode) reference.

### HTRB#document

The `document` method is a shortcut to create an `HTRB::Document` object. As such it takes all the arguments to construct that a `HTRB::Document` takes and returns the document object. See [HTRB::Document](#htrbdocument) reference.

---

## Custom Components

One of the most powerful things that **HTRB** can do is allow you to define your own custom components. In general, you do so by creating a class that inherits from `HTRB::Component` and overriding the `render` method:

```ruby
class CustomButton < HTRB::Component
  def render
    button_text = props.text

    a href: props.href, class: 'button' do
      t! button_text
    end
  end
end
```

In the above example, we create a `CustomButton` component, that when used will create an anchor element with the class `'button'` and a specified `href` and `text`. When we define `CustomButton`, **HTRB** will automatically create a `_custombutton!` method on `HtmlNode` that will allow you to insert this custom button anywhere you could HTML:

```ruby
HTRB.html do
  _custombutton! href: '/join', text: 'Join in!'
end # <a href="/join" class="button">Join in!</a>
```

To explain how passing data works, the `props` method will return the attributes passed to your custom tag as a hash, so you are able to access custom data anytime you use the tag. As `props` is an instance method, it is only go to reference your custom tag outside of other HTML blocks. It is best practice to extract the data you need into a local variable if you are going to use it inside another HTML element, like we did with `button_text = props.text`.

### Container Components

By default, custom components are considered self-closing tags. This means, if you try to pass a block to a custom component, it will raise a `HTRB::SelfClosingTagError`, not allowing you to define the inner contents of your custom tag. We can get around this by overiding the `self_closing?` method and using the `remit` method:

```ruby
class CustomContainer < HTRB::Component
  def render(&contents)
    div class: 'modal' do
      remit &contents
    end
  end

  def self_closing?
    false
  end
end
```

In the above, we create a custom container component by overriding the `self_closing?` method and returning false. This allows you to pass a block when using the component. We go one further by using the `remit` method to run the passed block inside the context of our div tag.

`remit` works a lot like the keywork `yield`, but it changes the context of the block to the instance it was called in. You could call it inside a child of your tag or in the tag itself, it doesn't matter. Whatever tags are called inside the block will be added as children to the context it was called in.

To call this custom container, is just like calling any other custom component. In this case it will be calling the `_customcontainer!` method and passing that a block:

```ruby
HTRB.html do
  _customcontainer! do
    strong! do
      t! 'In a container'
    end
  end
end # <div class="modal"><strong>In a container</strong></div>
```

---

## Reference
### HTRB::HtmlNode

Everything in **HTRB** is built around the `HtmlNode` object. Both `HTRB::Component` and `HTRB::Element` are subclasses of it and both automatically make relevant methods inside it for each tag generated.

While most probably will not manipulate the `HtmlNode` object, it is good to understand the public interface of it. It provides a simple dom like structure to forming pages, thus may have some use in generating full pages.

The `HtmlNode` class is private, thus you won't be constructing it in general by itself, but again its good to know.

#### HtmlNode#initialize
- `initialize(**attributes, &contents)`
  - Is used to construct an `HtmlNode` object
  - Will store the `attributes` hash in an instance variable accessible by the private `props` method and then immediately invoke the `render` method passing the `contents` block along
  - Generally will be called by generated methods for tags and `HTRB.fragment`/`HTRB.html`

#### HtmlNode#parent
  - Will return the parent node
- If it has no parent, it will be `nil`

#### HtmlNode#inner_html
- `inner_html()`
  - Returns a duplicate of the child array containing all direct child nodes
- `inner_html(&contents)`
  - Directly replaces the children with whatever the passed block evaluates to
  - All children will have their parent property changed to `nil`

#### HtmlNode#append
- `append(child)`
  - Appends a `child` to the `HtmlNode` instance
  - `child` must be a string or `HtmlNode`
      - If `child` is a string, it will not be HTML escaped unlike `t!`
      - If `child` is an `HtmlNode`, it will have its parent set to this object and removed from previous parent
      - if `child` is `self` or an ancestor of `self`, will raise a `HTRB::TagParadoxError`
  - Returns `child`

#### HtmlNode#insert
- `insert(child, where, at)`
  - Inserts a `child` in relation to the `at` child, removing child from previous parent
  - `child` must be a string or `HtmlNode`
  - `where` must be either `:before` or `:after`
  - `at` must be a child of the object
  - Returns `child`

#### HtmlNode#remove
- `remove(child)`
  - Removes the `child` from the object
  - Returns `child` if it was removed, `nil` otherwise

#### HtmlNode#to_s
- `to_s()`
  - converts the object and its children recursively into an html string with no formatting

#### HtmlNode#to_pretty
- `to_pretty()`
  - converts the object and its children recursively into an html string with tabs and newlines

### HTRB::Document

The document object is used to represent an entire HTML document instead of just fragments of one.

#### Document#initialize
- `initialize(**options, &body_content)`
  - The constructor will construct the core of the html document
  - There are only two available `options`
      - `title:` The title of the page
      - `head:` A proc to be executed to add to the `<head></head>` tag
          - By default the `<title>` and `<meta charset="UTF-8">` tags are already defined
  - `body_content` is the block passed to fill the `<body></body>` tag

#### Document#head
- `head(&new_contents)`
  - `new_contents` is the block passed to replace the contents of the `<head></head>` tag
  - The `<title>` and `<meta>` tag are still inserted

#### Document#body
- `body(&new_contents)`
  - `new_contents` is the block passed to replace the contents of the `<body></body>` tag

#### Document#title
- `title()`
  - Returns the title of the page
- `title(new_title)`
  - `new_title` is the new title for the page that replaces the old

#### Document#to_s
- `to_s()`
  - converts the document to an html string with no formatting

#### Document#to_pretty
- `to_pretty()`
  - converts the document to an html string with tabs and newlines
