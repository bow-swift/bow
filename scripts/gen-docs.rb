#!/usr/bin/env ruby
require 'json'

## VERSIONED DOCS GENERATION ##

# If you want a specific version to be served as default, set this value to the
# branch/tag you want. Otherwise it will be the latest version on alphabetical order.
# If there's no tags, then `master` branch content will be served at root path.
$default_version = "0.8.0"

# If you want to build the current branch (usually `master`) and serve it,
# set the path/name in here. If you leave it empty no site will be built for it.
$current_branch_path = "next"

# This is a list to filter -out- tags we know are not valuable to generate docs
# for. If you set one tag in the default_version, you can add it here, so it's
# not generated twice. Unless you want to have the same content at two paths.
$invalid_tags = ["0.1.0", "0.2.0", "0.3.0", "0.4.0", "0.5.0", "0.6.0", "0.7.0", "0.8.0"]

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
  "BowEffects", "BowRx", "Bow"]



# Generate the JSON files that will be needed later.
# Modules present in the project are used to split the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def generate_json(version)
  system "echo == Generating JSON API data for #{version}"
  `mkdir -p #{$json_files_dir}/#{version}`
  $modules.each { |m| `sourcekitten doc --spm-module #{m} > #{$json_files_dir}/#{version}/#{m}.json` }
end

# Join the previously generated JSON files into one single file.
# The array of modules in the project is used to join the JSON info.
#
# @param version [String] The version for which the JSON will be generated.
# @return [nil] nil.
def join_json(version)
  system "echo == Joining all different JSON API data for #{version}"
  joined = []
  $modules.map { |m| JSON.parse(File.read("#{$json_files_dir}/#{version}/#{m}.json")) } \
    .each { |json| joined += json }

  File.open("#{$json_files_dir}/#{version}/all.json","w") do |f|
    f.write(joined.to_json)
  end
end

# Generate the nef site based on the contents source.
#
# @param version [String] The version for which the nef docs site will be generated.
# @param versions_list [Array] The list of versions available to select in the whole project.
# @return [nil] nil.
def generate_nef_site(title, version, versions_list)
  system "echo == Generating nef site for #{version}"
  `mkdir -p #{$source_dir}/_data`
  this_versions = versions_list.dup;
  version_index = versions_list.index { |s| s["title"] == "#{title}" }
  this_version = this_versions[version_index]
  this_versions[version_index] = {
    "title" => "#{title}",
    "version" => "#{version}",
    "this" => true
  };
  File.write("#{$source_dir}/_data/versions.json", JSON.pretty_generate(this_versions))

  # Removing lockfile to avoid conflict in case it differs between versions
  system "rm #{$source_dir}/Gemfile.lock"
  system "nef jekyll --project Documentation.app --output #{$source_dir} --main-page Documentation.app/Jekyll/Home.md"
end

# Generate the Jekyll site.
#
# @param version [String] The version for which the nef docs site will be generated.
# @param is_default [Bool] Given version is the default.
def render_jekyll(version, is_default)
  if is_default
      `mkdir -p #{$gen_docs_dir}/#{version}`
      system "cp -R #{$source_dir}/ #{$gen_docs_dir}/#{version}/"
      system "rm -rf #{$gen_docs_dir}/#{version}/vendor"
  else
      system "JEKYLL_ENV=production BUNDLE_GEMFILE=./#{$source_dir}/Gemfile bundle exec jekyll build -s ./#{$source_dir} -d ./#{$gen_docs_dir}/#{version} -b #{version}"
      system "rm -rf #{$source_dir}/docs"
  end

  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Generate the Jazzy site based on previouly created JSON file.
#
# @param version [String] The version for which the Jazzy API docs site will be generated.
# @return [nil] nil.
def generate_api_site(version)
  system "echo == Generating API site for #{version}"
  # Removing lockfile to avoid conflict in case it differs between versions
  system "rm #{$source_dir}/Gemfile.lock"
  system "BUNDLE_GEMFILE=#{$source_dir}/Gemfile bundle exec jazzy -o ./#{$gen_docs_dir}/#{version}/api-docs --sourcekitten-sourcefile #{$json_files_dir}/#{version}/all.json --author Bow --author_url https://bow-swift.io --module Bow --root-url https://bow-swift.io/#{version}/api-docs/ --github_url https://github.com/bow-swift/bow --theme docs/extra/bow-jazzy-theme"
  system "ls -la #{$gen_docs_dir}/#{version}"
end

# Initially, we save the name of the current branch/tag to be used later
current_branch_tag = `git name-rev --name-only HEAD`
system "echo == Current branch/tag is #{current_branch_tag}"

#This is the list of versions that will be built, and used, as part of the process
versions = []
versions.unshift({
  "title" => "#{$default_version}",
  "version" => "#{$default_version}",
})

# Besides default, another version that will be available to select will be
# the current branch/tag, if desired through the use of $current_branch_path
if !$current_branch_path.to_s.empty?
  versions.push({
    "title" => "#{$current_branch_path}",
    "version" => "#{current_branch_tag.rstrip()}",
  })
end

# Directory initialization
`mkdir -p #{$json_files_dir}`
`mkdir -p #{$publishing_dir}`
`mkdir -p #{$gen_docs_dir}`

# Initial generic logic and dependencies for the docs site
system "echo == Installing ruby dependencies"
system "bundle install --gemfile #{$source_dir}/Gemfile --path vendor/bundle"

# Following logic will process and generate the different releases specific sites

# Then, tags will contain the list of Git tags present in the repo
tags = `git tag`.split("\n")
system "echo == The tags present in the repo are #{tags}"

# This is done to avoid the need to write down all the tags when we want everything in
if !$valid_tags.any?
  $valid_tags = tags
end

if tags.any?
  filtered_out_tags = tags.reject { |t| $invalid_tags.include? t }
  filtered_tags = filtered_out_tags.select { |t| $valid_tags.include? t }
  system "echo == And the tags that will be actually processed are #{filtered_tags}"
  # First iteration is done to have the list of versions available
  filtered_tags.each { |t|
                        versions.push({
                          "title" => "#{t}",
                          "version" => "#{t}",
                        })
                      }

  if $default_version.to_s.empty?
    if filtered_tags.any?
      $default_version = filtered_tags.last
    else
      $default_version = "master"
    end
  end
end


# Now, we generate the content available at the initial branch (master?) + default_version
versions.each { |this_version|
    title = this_version["title"]
    version = this_version["version"]

    if !"#{version}".to_s.empty?
      `git checkout -f #{version}`
      system "echo == Current branch/tag is now #{version}"
      system "echo == Compiling the library in #{version}"
      system "swift package clean"
      system "swift build"
      generate_nef_site("#{title}", "#{version}", versions)
      render_jekyll("#{title}", "#{version}" == "#{$default_version}")
      generate_json("#{title}")
      join_json("#{title}")
      generate_api_site("#{title}")
    end
}


# Now we need to move default API docs to the default publishing location too.
`mv #{$gen_docs_dir}/#{$default_version}/* #{$gen_docs_dir}/`
`rm -rf #{$gen_docs_dir}/#{$default_version}`

# We also move the rest of version generated sites to its publishing destination
`mv #{$gen_docs_dir}/* #{$publishing_dir}/`
