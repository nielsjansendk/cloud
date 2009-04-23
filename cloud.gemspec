# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{ninajansen-cloud}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nina Jansen"]
  s.date = %q{2009-04-23}
  s.description = %q{Generates pdf-files with word clouds based on input. Inspired by wordle, but probably uses an entirely different algorithm, since Wordle is not Open Source.}
  s.email = ["info@ninajansen.dk"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/cloud.rb", "lib/cloud/cloud.rb","lib/cloud/object_stash.rb","lib/cloud/rss.rb","lib/cloud/wordbox.rb","script/console", "script/destroy", "script/generate", "test/test_cloud.rb", "test/test_helper.rb", "test/test_wordbox.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Generates pdf-files with word clouds based on input}
  s.test_files = ["test/test_cloud.rb", "test/test_helper.rb", "test/test_wordbox.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_runtime_dependency(%q<RubyInline>, [">= 3.8.1"]) 
      s.add_runtime_dependency(%q<pdf-writer>, [">= 1.1.8"]) 
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_dependency(%q<RubyInline>, [">= 3.8.1"]) 
      s.add_dependency(%q<pdf-writer>, [">= 1.1.8"]) 
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    s.add_dependency(%q<RubyInline>, [">= 3.8.1"]) 
    s.add_dependency(%q<pdf-writer>, [">= 1.1.8"]) 
  end
end


