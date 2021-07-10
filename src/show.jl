import Base: show

#
# Utility functions
#

function _showindent(io::IO)
	indent = get(io, :indent, 0)
	for _ in 1:indent
		write(io, "  ")
	end
end


function _xmlescape(t::AbstractString)
	# Technically these are not all always required, but to be safe
	t = replace(t, "&"=>"&amp;")
	t = replace(t, "\""=>"&quot;")
	t = replace(t, "'"=>"&apos;")
	t = replace(t, "<"=>"&lt;")
	t = replace(t, ">"=>"&gt;")
	t
end
_xmlescape(t) = _xmlescape(string(t))

#
# Text Node
#

function Base.show(io::IO, mime::MIME"text/plain", el::TextNode)
	compact = get(io, :compact, false)
	compact || _showindent(io)
	show(io, mime, el.text)
	return nothing
end

function Base.show(io::IO, ::MIME"text/xml", el::TextNode)
	write(io, el.text |> string |> _xmlescape)
	return nothing
end

#
# Generic Element
#

function Base.show(io::IO, mime::MIME"text/plain", e::Element{ns, tag}) where{ns, tag}
	compact = get(io, :compact, false)
	compact || _showindent(io)
	write(io,"(")
	if ns !== :nothing
		write(io, ns)
		write(io, ":")
	end
	write(io, tag)
	for (prop, value) in e.props
		write(io, " ")
		write(io, prop)
		write(io,"=")
		show(io, mime, value)
	end
	if !isempty(e.children)
		depth = get(io, :depth, 0)
		child_io = IOContext(io, 
			:indent => get(io, :indent, 0) + 1,
			:depth => depth + 1,
			:compact => compact || depth > 2
		)
		for child in e.children
			compact ? write(io, " ") : write(io, "\n")
			# if depth > 2 and !compact, then we should do our own indenting on the children, because they won't
			# Not sure if this makes sense
			compact || depth > 2 && _showindent(child_io)
			show(child_io, mime, child)
		end
		compact || write(io, "\n")
		compact || _showindent(io)
	end
	write(io, ")")
	return nothing
end

function Base.show(io::IO, mime::MIME"text/xml", e::Element{ns, tag}) where {ns, tag}
	write(io, "<")
	if ns !== :nothing
		write(io, _xmlescape(ns))
	end
	write(io, _xmlescape(string(tag)))
	for (prop, value) in e.props
		write(io, " ")
		write(io, _xmlescape(prop))
		write(io,"=\"")
		write(io, _xmlescape(value))
		write(io, "\"")
	end
	if !isempty(e.children)
		write(io, ">")
		for child in e.children
			show(io, mime, child)
		end
		write(io, "</")
		if ns !== :nothing
			write(io, _xmlescape(ns))
		end
		write(io, _xmlescape(string(tag)))
		write(io, ">")
	else
		write(io, "/>")
	end
	return nothing;
end
Base.show(io::IO, ::MIME"text/html", e::Element) = Base.show(io, MIME("text/xml"), e)
Base.show(io::IO, ::MIME"image/svg", e::Element) = Base.show(io, MIME("text/xml"), e)
