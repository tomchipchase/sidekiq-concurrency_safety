require_relative 'lib/sidekiq/concurrency_safety/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-concurrency_safety"
  spec.version       = Sidekiq::ConcurrencySafety::VERSION
  spec.authors       = ["Tom Chipchase"]
  spec.email         = ["tom.chipchase@farmdrop.co.uk"]

  spec.summary       = %q{Prevent multiple sidekiq jobs with the same arguments from running at the same time.}
  spec.homepage      = "https://github.com/tomchipchase/sidekiq-concurrency_safety"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
