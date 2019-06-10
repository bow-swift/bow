#!/usr/bin/env ruby
require 'json'

## DOCS GEN ##

# If you want a specific version set this value to the one you want.
# Otherwise the version will be the latest on alphabetical order.
default_version = ""

# This is a list of tags we know are not valuable to generate docs for
invalid_tags = ["0.1.0", "0.2.0", "0.3.0"]

# If instead you want to set the list of versions to show
# as a positive list, do it so here
valid_tags = []

modules = ["BowOptics", "BowRecursionSchemes", "BowGeneric", "BowFree", \
  "BowEffects", "BowRx", "BowBrightFutures", "Bow"]

# Generate the JSON files that will be needed later.
#
# @param version [String] tfgfgfgfg
# @param modules [Array] dfdgfg`
# @return [nil] nil.
def generate_json(version, modules)
  `mkdir -p docs-json/#{version}`
  modules.each { |m| `sourcekitten doc --spm-module #{m} > ./docs-json/#{version}/#{m}.json` }
end

# Join the previously generated JSON files into one single file.
#
# @param version [String] tfgfgfgfg
# @param modules [Array] dfdgfg`
# @return [nil] nil.
def join_json(version, modules)
  joined = []
  modules.map { |m| JSON.parse(File.read("./docs-json/#{version}/#{m}.json")) } \
    .each { |json| joined += json }

  File.open("./docs-json/#{version}/all.json","w") do |f|
    f.write(joined.to_json)
  end
end

# Generate the Jekyll site through Nef based on the contents source.
#
# @param version [String] tfgfgfgfg
# @return [nil] nil.
def generate_nef_site(version)
  system "echo Generating nef site for #{version}"
  # system "mkdir -p docs/#{version}/_data"
  system "nef jekyll --project contents/Documentation --output docs --main-page contents/Home.md"
  # system "nef jekyll --project contents/Documentation --output docs/#{version} --main-page contents/Home.md"
  system "JEKYLL_ENV=production BUNDLE_GEMFILE=./docs/Gemfile bundle exec jekyll build -s ./docs -d ./docs/#{version} -b bow/#{version}"
  system "ls -la docs"
  system "ls -la docs/#{version}"
end

# Generate the Jazzy site based on previouly created JSON file.
#
# @param version [String] tfgfgfgfg
# @return [nil] nil.
def generate_api_site(version)
  system "echo Generating API site for #{version}"
  system "BUNDLE_GEMFILE=./docs/Gemfile bundle exec jazzy -o ./docs/#{version}/api-docs --sourcekitten-sourcefile ./docs-json/#{version}/all.json --author Bow --author_url https://bow-swift.io --github_url https://github.com/bow-swift/bow --module Bow --root-url https://bow-swift.io/#{version}/api-docs --theme docs/extra/bow-jazzy-theme"
  system "ls -la docs"
  system "ls -la docs/#{version}"
end

# Initial generic logic and depencies for the docs site
`mkdir -p docs-json`
system "swift package clean"
system "swift build"
system "bundle install --gemfile ./docs/Gemfile --path vendor/bundle"

# Here we generate the content available at rootpath
generate_json("snapshot", modules)
join_json("snapshot", modules)
generate_nef_site("snapshot")
generate_api_site("snapshot")

# Code to generate the different release specific sites

# tags will contains the list of Git tags present in our repository
tags = `git tag`.split("\n")
filtered_tags = tags.reject { |t| invalid_tags.include? t }
filtered_tags.each { |t|
                      system "git checkout #{t}"
                      system "swift package clean"
                      system "swift build"
                      generate_nef_site("#{t}")
                      generate_json("#{t}", modules)
                      join_json("#{t}", modules)
                      generate_api_site("#{t}")
                    }

`git checkout 0.4.0`
