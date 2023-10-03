require_relative "lib/htrb/version"

Gem::Specification.new do |s|
  s.name = 'htrb'
  s.version = Htrb::VERSION
  s.authors = ['Christopher Perkins']
  s.email = ['Christopher.Perkins@null.net']

  s.summary = 'htrb is a dsl for html and webcomponents'
  s.licenses = ['MIT']

  s.files = [
    'lib/htrb.rb',
    'lib/version.rb',
    'lib/html_elements.rb',
  ]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0")
end
