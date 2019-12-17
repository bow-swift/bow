Pod::Spec.new do |s|
  s.name        = "BowFree"
  s.version     = "0.7.0"
  s.summary     = "Bow is a library for Typed Functional Programming in Swift. BowFree provides classes to work with Free Monads."
  s.homepage    = "https://github.com/bow-swift/bow"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.authors     = "The Bow authors"

  s.requires_arc = true
  s.osx.deployment_target = "10.10"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.1"
  s.watchos.deployment_target = "2.0"
  s.source   = { :git => "https://github.com/bow-swift/bow.git", :tag => "#{s.version}" }
  s.source_files = "Sources/BowFree/**/*.swift"
  s.dependency "Bow", "~> #{s.version}"
  s.swift_versions = ["5.0", "5.1"]
end
