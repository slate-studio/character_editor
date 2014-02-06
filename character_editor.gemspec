# -*- encoding: utf-8 -*-
require File.expand_path('../lib/character_editor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'character_editor'
  gem.version       = Character::Editor::VERSION
  gem.summary       = 'Character WYSIWYG editor'
  gem.license       = 'MIT'

  gem.authors       = ['Alexander Kravets']
  gem.email         = 'alex@slatestudio.com'
  gem.homepage      = 'https://github.com/slate-studio/character_editor'

  gem.require_paths = ['lib']
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  # Supress the warning about no rubyforge project
  gem.rubyforge_project = 'nowarning'
end