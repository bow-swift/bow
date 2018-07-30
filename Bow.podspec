Pod::Spec.new do |s|
  s.name        = "Bow"
  s.version     = "0.1.0"
  s.summary     = "Bow is a library for Typed Functional Programming in Swift."
  s.homepage    = "https://github.com/arrow-kt/bow"
  s.license     = { :type => "Copyright" }
  s.authors     = "The Bow authors"

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.1"
  s.watchos.deployment_target = "2.0"  
  s.source   = { :git => "https://github.com/arrow-kt/bow.git", :tag => "#{s.version}" }
  s.source_files = "Sources/Bow/*.swift"
end
