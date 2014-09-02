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

	# needs to replace round bracket contents ONLY IF they are not enclosed in square brackets
	content = content[content.index(/[']{3}/), content.length - content.index(/[']{3}/)].gsub(/\(.*?\)/, '').gsub(/<ref>\s*.*\s*<\/ref>/, '')

	link = content.match(/[^']{2}\[\[([\w |\(\)]*)[\w ]*\]\][^']{2}/)
	actual_link = link.to_s.scan(/\[\[([\w ()]*)[|]?[\w ()]*\]\]/)[0][0].to_s

	puts "*", link, "*", actual_link, "*"

	foreal(actual_link, visited)
end