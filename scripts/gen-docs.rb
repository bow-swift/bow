#!/usr/bin/env ruby
require 'json'

## VERSIONED DOCS GENERATION ##

# If you want a specific version to be served as default, set this value to the
# branch/tag you want. Otherwise it will be the latest version on alphabetical order.
# If there's no tags, then `master` branch content will be served at root path.
$default_version = "master"

# If you want to build the current branch (usually `master`) and serve it,
# set the path/name in here. If you leave it empty no site will be built for it.
$current_branch_path = "next"

# This is a list to filter -out- tags we know are not valuable to generate docs
# for. If you set one tag in the default_version, you can add it here, so it's
# not generated twice. Unless you want to have the same content at two paths.
$invalid_tags = ["0.1.0", "0.2.0", "0.3.0"]

# This is a list to filter -in- tags. Unless it's empty, where it will be ignored.
# If you want an empty tags list in the end (for some reason ¯\_(ツ)_/¯)
# you can cancel these filterings with both lists having the same values:
# invalid_tags = ["0.1.0"], valid_tags = ["0.1.0"]
$valid_tags = []

# The path of the dir where the Jekyll source is located.
$source_dir = "docs"

# The path of the dir that will be published. Check out GitHub Pages/Travis for this.
$publishing_dir = "pub-dir"

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
  $modules.each { |m| `sourcekitten doc --spm-module #{m} > #{$json_files_dir}/#{version}/#{m}.json` }
end

# Join the previously generated JSON files into one single file.
# The array of modules in the project is used to join the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def join_json(version)
  joined = []
  $modules.map { |m| JSON.parse(File.read("#{$json_files_dir}/#{version}/#{m}.json")) } \
    .each { |json| joined += json }

  File.open("#{$json_files_dir}/#{version}/all.json","w") do |f|
    f.write(joined.to_json)
  end
end

# Generate the Jekyll site through Nef based on the contents source.
#
# @param version [String] The version for which the nef docs site will be generated.
# @param versions_list [Array] The list of versions available to select in the whole project.
# @return [nil] nil.
def generate_nef_site(version, versions_list)
  system "echo Generating nef site for #{version}"
  this_versions = versions_list.dup;
  this_versions[versions_list.find_index("title" => version)] = {
    "title" => version,
    "this" => true
  };
  `mkdir -p #{$gen_docs_dir}/#{version}/_data`
  File.write("#{$gen_docs_dir}/#{version}/_data/versions.json", JSON.pretty_generate(this_versions))
  # system "nef jekyll --project contents/Documentation --output docs --main-page contents/Home.md"
  # system "JEKYLL_ENV=production BUNDLE_GEMFILE=./docs/Gemfile bundle exec jekyll build -s #{$source_dir} -d #{$gen_docs_dir}/#{version} -b bow/#{version}"
  # system "ls -la #{$source_dir}"
  # system "ls -la #{$gen_docs_dir}/#{version}"
end

# Generate the Jazzy site based on previouly created JSON file.
#
# @param version [String] The version for which the Jazzy API docs site will be generated.
# @return [nil] nil.
def generate_api_site(version)
  system "echo Generating API site for #{version}"
  system "BUNDLE_GEMFILE=#{$source_dir}/Gemfile bundle exec jazzy -o #{$gen_docs_dir}/#{version}/api-docs --sourcekitten-sourcefile #{$json_files_dir}/#{version}/all.json --author Bow --author_url https://bow-swift.io --github_url https://github.com/bow-swift/bow --module Bow --root-url https://bow-swift.io/#{version}/api-docs --theme docs/extra/bow-jazzy-theme"
  system "ls -la #{$source_dir}"
  system "ls -la #{$gen_docs_dir}/#{version}"
end


#This is the list of versions that will be built as part of this process
versions = []
versions.unshift({
  "title" => $default_version,
})

# Directory initialization
`mkdir -p #{$json_files_dir}`
`mkdir -p #{$publishing_dir}`
`mkdir -p #{$gen_docs_dir}`

# Initial generic logic and dependencies for the docs site
# system "swift package clean"
# system "swift build"
# system "bundle install --gemfile #{$source_dir}/Gemfile --path vendor/bundle"

# Initially, we generate the content available at current branch (master?)
# to be at $current_branch_path (/next?) path
if !$current_branch_path.to_s.empty?
  versions.push({
    "title" => $current_branch_path,
  })
  # generate_json($current_branch_path)
  # join_json($current_branch_path)
  generate_nef_site($current_branch_path, versions)
  # generate_api_site($current_branch_path)
  # puts $current_branch_path
end

# Following logic will process and generate the different releases specific sites

# Then, tags will contain the list of Git tags present in the repo
tags = `git tag`.split("\n")

# This is done to avoid the need to write down all the tags when we want everything in
if !$valid_tags.any?
  $valid_tags = tags
end

if tags.any?
  filtered_out_tags = tags.reject { |t| $invalid_tags.include? t }
  filtered_tags = filtered_out_tags.select { |t| $valid_tags.include? t }
  # First iteration is done to have the list of versions available
  filtered_tags.each { |t|
                        versions.push({
                          "title" => t,
                        })
                      }
  filtered_tags.each { |t|
                        system "git checkout #{t}"
                        # system "swift package clean"
                        # system "swift build"
                        generate_nef_site("#{t}", versions)
                        # generate_json("#{t}")
                        # join_json("#{t}")
                        # generate_api_site("#{t}")
                      }

  if filtered_tags.any?
    if $default_version.to_s.empty?
      $default_version = filtered_tags.last
    end
  else
    $default_version = "master"
  end
end


# The content available in the default branch will be generated by GH Pages itself
`git checkout #{$default_version}`
`mkdir -p #{$gen_docs_dir}/#{$default_version}/_data`
this_versions = versions.dup;
this_versions[this_versions.find_index("title" => $default_version)] = {
  "title" => $default_version,
  "this" => true
};
File.write("#{$gen_docs_dir}/#{$default_version}/_data/versions.json", JSON.pretty_generate(this_versions))
# File.write("versions.json", JSON.pretty_generate($versions))

# And then, we need to generate the API docs for the default version
# generate_json("#{$default_version}")
# join_json("#{$default_version}")
# generate_api_site("#{$default_version}")

# Now we need to move default API docs to the default publishing location too.
# `mv #{$gen_docs_dir}/#{$default_version}/api-docs #{$gen_docs_dir}/`

# We also move the version generated sites to its publishing destination
# `mv #{$gen_docs_dir}/* #{$publishing_dir}/`

# And finally we move the source to the directory that will be published.
# Remember that this should be the same directory set in GH Pages/Travis.
# `mv #{$source_dir}/* #{$publishing_dir}/`
