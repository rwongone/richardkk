require 'wikipedia'

def foreal(query, visited)
	puts query
	result = Wikipedia.find(query)

	content = result.content
	title = result.title
	if (title == "Philosophy")
		visited.push("You did it!")
		return visited
	elsif (!visited.include?(title))
		visited.push(title)
	else
		visited.push("We have reached a cycle at " + title + ".")
		return visited
	end

	if (content.nil?)
		return visited
	end

	content = content[content.index(/[']{3}/), content.length - content.index(/[']{3}/)].gsub(/\(.*?\)/, '').gsub(/<ref>\s*.*\s*<\/ref>/, '')

	puts content

	link = content.match(/[^']{0,2}\[\[([\w ]*)[|]?[\w ]*\]\][^']{0,2}/)
	actual_link = link.to_s.scan(/\[\[([\w ]*)[|]?[\w ]*\]\]/)

	puts "*", link, "*", actual_link, "*"

	foreal(actual_link, visited)
end