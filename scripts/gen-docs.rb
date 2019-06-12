#!/usr/bin/env ruby
require 'json'
require 'FileUtils'

## VERSIONED DOCS GENERATION ##

# If you want a specific version to be served as default, set this value to the
# branch/tag you want. Otherwise it will be the latest version on alphabetical order.
$default_version = "master"

# This is a list to filter -out- tags we know are not valuable to generate docs for.
$invalid_tags = ["0.1.0", "0.2.0", "0.3.0"]

# This is a list to filter -in- tags. Unless it's empty, where it will be ignored.
# If you want an empty tags list in the end (for some reason ¯\_(ツ)_/¯)
# you can cancel these filterings with both lists having the same values:
# invalid_tags = ["0.1.0"], valid_tags = ["0.1.0"]
$valid_tags = []

# The path of the dir where the Keyll source is located.
$source_dir = "docs"

# The path of the dir that will be published. Check out GitHub Pages/Travis for this.
$publishing_dir = "docs"

# The path of the dir to temporarily store the different sites content.
$gen_docs_dir = "gen-docs"

# The path of the dir to temporarily store the JSON files for API sites.
$json_files_dir = "json-files"

# This a list of modules in which the Swift project is split on
$modules = ["BowOptics", "BowRecursionSchemes", "BowGeneric", "BowFree", \
  "BowEffects", "BowRx", "BowBrightFutures", "Bow"]


# Generate the JSON files that will be needed later.
# Modules present in the project are used to split the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def generate_json(version)
  `mkdir -p #{$json_files_dir}/#{version}`
  $modules.each { |m| `sourcekitten doc --spm-module #{m} > #{json_files_dir}/#{version}/#{m}.json` }
end

# Join the previously generated JSON files into one single file.
# The array of modules in the project is used to join the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def join_json(version, modules)
  joined = []
  $modules.map { |m| JSON.parse(File.read("#{json_files_dir}/#{version}/#{m}.json")) } \
    .each { |json| joined += json }

  File.open("#{json_files_dir}/#{version}/all.json","w") do |f|
    f.write(joined.to_json)
  end
end

# Generate the Jekyll site through Nef based on the contents source.
#
# @param version [String] The version for which the nef docs site will be generated.
# @return [nil] nil.
def generate_nef_site(version)
  system "echo Generating nef site for #{version}"
  system "nef jekyll --project contents/Documentation --output docs --main-page contents/Home.md"
  system "JEKYLL_ENV=production BUNDLE_GEMFILE=./docs/Gemfile bundle exec jekyll build -s #{$source_dir} -d #{$gen_docs_dir}/#{version} -b bow/#{version}"
  # system `rm -rf`
  system "ls -la #{$source_dir}"
  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Generate the Jazzy site based on previouly created JSON file.
#
# @param version [String] The version for which the Jazzy API docs site will be generated.
# @return [nil] nil.
def generate_api_site(version)
  system "echo Generating API site for #{version}"
  system "BUNDLE_GEMFILE=#{$source_dir}/Gemfile bundle exec jazzy -o #{$gen_docs_dir}/#{version}/api-docs --sourcekitten-sourcefile #{json_files_dir}/#{version}/all.json --author Bow --author_url https://bow-swift.io --github_url https://github.com/bow-swift/bow --module Bow --root-url https://bow-swift.io/#{version}/api-docs --theme docs/extra/bow-jazzy-theme"
  system "ls -la #{$source_dir}"
  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Auxiliary function that helps to move files. Using native `mv` could lead
# to errors due to the way the shell handle glob patterns.
#
# @param src [String] The version for which the Jazzy API docs site will be generated.
# @param dest [String] The version for which the Jazzy API docs site will be generated.
# @return [nil] nil.
def archive_src_to_dst_dir(src, dst)
  if File.exist?(src)
    puts "about to move this file: #{src}"
    FileUtils.mv(src, dst)
  else
    puts "can not find source file to move"
  end
end


# Directory initialization
`mkdir -p #{$json_files_dir}`
`mkdir -p #{$publishing_dir}`
`mkdir -p #{$gen-docs}`

# Initial generic logic and dependencies for the docs site
system "swift package clean"
system "swift build"
system "bundle install --gemfile #{$source_dir}/Gemfile --path vendor/bundle"

# Following logic will process and generate the different releases specific sites

# Initially, we generate the content available at master to be at /next path
generate_json("next")
join_json("next")
generate_nef_site("next")
generate_api_site("next")

# Then, tags will contain the list of Git tags present in the repo
tags = `git tag`.split("\n")

# This is done to avoid the need to write down all the tags when we want everything in
if !$valid_tags.any?
  $valid_tags = tags
end

if tags.any?
  filtered_out_tags = tags.reject { |t| $invalid_tags.include? t }
  filtered_tags = filtered_out_tags.select { |t| $valid_tags.include? t }
  filtered_tags.each { |t|
                        system "git checkout #{t}"
                        system "swift package clean"
                        system "swift build"
                        generate_nef_site("#{t}")
                        generate_json("#{t}")
                        join_json("#{t}")
                        generate_api_site("#{t}")
                      }
end


# The content available in the default branch will be generated by GH Pages itself
if tags.any?
  if $default_version.to_s.empty?
    `git checkout #{tags.last}`
  else
    `git checkout #{$default_version}`
  end
  # We finally move the source and version generated sites under /docs, (probably)
  # and this should be the same directory set in Travis to be published.
  `mv #{$gen_docs_dir}/* #{$publishing_dir}/`
end

`mv #{$source_dir}/* #{$publishing_dir}/`
