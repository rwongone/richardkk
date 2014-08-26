require 'wikipedia'

def foreal(query, visited)
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

	link = content.match(/[^']{0,2}\[\[([\w ]*)[|]?[\w ]*\]\][^']{0,2}/)
	actual_link = link.to_s.scan(/\[\[([\w ]*)\]\]/)

	foreal(actual_link, visited)
end