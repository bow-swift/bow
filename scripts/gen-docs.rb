#!/usr/bin/env ruby
require 'json'

system 'swift package clean'
system 'swift build'
system 'mkdir docs-json || true'

modules = ["BowOptics", "BowRecursionSchemes", "BowGeneric", "BowFree", \
  "BowEffects", "BowRx", "BowBrightFutures", "Bow"]
modules.each { |m| system "sourcekitten doc --spm-module #{m} > ./docs-json/#{m}.json" }

joined = []
modules.map { |m| JSON.parse(File.read("./docs-json/#{m}.json")) } \
  .each { |json| joined += json }

File.open("./docs-json/all.json","w") do |f|
  f.write(joined.to_json)
end

system 'bundle install --gemfile ./docs/Gemfile --path vendor/bundle'
system 'BUNDLE_GEMFILE=./docs/Gemfile bundle exec jazzy -o ./docs/api-docs --sourcekitten-sourcefile ./docs-json/all.json --author Bow --author_url https://bow-swift.io --github_url https://github.com/bow-swift/bow --module Bow --root-url https://bow-swift.io/api-docs --theme docs/extra/bow-jazzy-theme'
