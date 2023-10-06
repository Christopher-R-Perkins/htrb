require_relative "lib/htrb/version"

Gem::Specification.new do |s|
  s.name = 'htrb'
  s.version = HTRB::VERSION
  s.authors = ['Christopher Perkins']
  s.email = ['Christopher.Perkins@null.net']
  s.homepage = 'https://github.com/QuasariNova/htrb'

  s.summary = 'HTRB is a dsl for html and webcomponents'
  s.licenses = ['MIT']

  s.files = [
    'lib/htrb.rb',
    'lib/htrb/version.rb',
    'lib/htrb/html_node.rb',
    'lib/htrb/html_elements.rb',
    'lib/htrb/htrb_base.rb',
    'lib/htrb/html_document.rb',
    'lib/htrb/component.rb',
    'test/htrb_test.rb',
    'README.md',
    'Gemfile',
  ]

  s.required_ruby_version = Gem::Requirement.new(">= 3.0")
end
