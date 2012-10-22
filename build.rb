#!/usr/bin/env ruby

require "rubygems"
require "hpricot"

if ARGV.length < 1
    abort("Usage: ./build.rb <HTML input file>")
end

doc = File.open(ARGV[0]) { |file| Hpricot(file) }

# Remove existing style tags
doc.search("style").remove

# Insert new stylesheet link
head = doc.search("head")
head.append '<link rel="stylesheet" href="style.css" />'

# Extract <pre> blocks and tables which are buried inside a <blockquote>
doc.search("blockquote").each do |bq|
  inner = bq.at("pre")
  if inner.nil?
    inner = bq.at("table")
  end
  
  unless inner.nil?
    bq.swap(inner.to_html)
  end
end

$stdout.write(doc.to_html)
