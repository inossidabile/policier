# frozen_string_literal: true

require_relative "lib/policier/version"

Gem::Specification.new do |spec|
  spec.name = "policier"
  spec.version = Policier::VERSION
  spec.authors = ["Boris Staal"]
  spec.email = ["boris@staal.io"]

  spec.summary = "The policier"

  spec.homepage = "https://staal.io"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-inflector", "~> 1.0.0"
end
