#!/usr/bin/env ruby

require "rubygems"
require "nokogiri"

if ARGV.length < 1
    abort("Usage: ./build.rb <HTML input file>")
end

doc = File.open(ARGV[0]) { |file| Nokogiri::HTML(file) }

# Remove existing style tags
doc.css("style").remove

# Insert new stylesheet and JavaScript links
head = doc.css("head").first
head.add_child "<link rel=\"stylesheet\" href=\"style.css\" />\n"
head.add_child "<script type=\"text/javascript\" src=\"hyphenator.js\"></script>\n"

# Insert Google Analytics code
head.add_child <<EOS
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
doc.css("body").first["class"] = "hyphenate"

# But don't hyphenate the table of contents, if it exists
contents = doc.css("div.contents")
unless contents.empty?
  contents.first["class"] = "contents donthyphenate"
  contents.first.first_element_child.before "<a href=\"index.html\"><img class=\"home-button\" src=\"home.png\" alt=\"Home\" /></a>"
end

# Extract <pre> blocks and tables which are buried inside a <blockquote>
doc.css("blockquote").each do |bq|
  inner = bq.css("pre")
  inner = bq.css("table") if inner.empty?
  
  bq.swap(inner.first) unless inner.empty?
end

$stdout.write(doc.to_xhtml)
