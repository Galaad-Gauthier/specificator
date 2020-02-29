
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "specificator/version"

Gem::Specification.new do |spec|
  spec.name          = "specificator"
  spec.version       = Specificator::VERSION
  spec.authors       = ["Galaad"]
  spec.email         = ["galaad.g@amusenetwork.com"]

  spec.summary       = %q(Build associations & validations specs automatically with shoulda-matchers)

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
