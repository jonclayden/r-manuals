#!/usr/bin/env ruby

require "rubygems"
require "hpricot"

if ARGV.length < 1
    abort("Usage: ./build.rb <HTML input file>")
end

doc = File.open(ARGV[0]) { |file| Hpricot(file) }

# Remove existing style tags
doc.search("style").remove

# Insert new stylesheet and JavaScript links
head = doc.search("head")
head.append "<link rel=\"stylesheet\" href=\"style.css\" />\n"
head.append "<script type=\"text/javascript\" src=\"hyphenator.js\"></script>\n"

# Insert Google Analytics code
head.append <<EOS
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-563735-8']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
EOS

# Set body class to ensure everything is hyphenated
doc.at("body").attributes["class"] = "hyphenate"

# But don't hyphenate the table of contents, if it exists
contents = doc.at("div.contents")
contents.attributes["class"] = "contents donthyphenate" unless contents.nil?

# Extract <pre> blocks and tables which are buried inside a <blockquote>
doc.search("blockquote").each do |bq|
  inner = bq.at("pre")
  inner = bq.at("table") if inner.nil?
  
  bq.swap(inner.to_html) unless inner.nil?
end

$stdout.write(doc.to_html)
