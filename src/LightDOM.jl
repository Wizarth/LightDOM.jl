module LightDOM

import Base: convert,
	length,
	show

export 	Node,
	TextNode,
	Element,
	text,
	count

#
# Utility functions
#

function _showindent(io::IO)
	indent = get(io, :indent, 0)
	for _ in 1:indent
		write(io, "\t")
	end
end


#
# Node base
#

abstract type Node end

#
# Text Node
#

struct TextNode <: Node
	text::AbstractString
end

"""
	text("This is Text)

	Creates a TextNode
"""
text(xs...) = TextNode(string(xs...))

"""
	convert a string to a Node
"""
Base.convert(::Type{Node}, s::AbstractString) = text(s)


function Base.show(io::IO, el::TextNode)
	_showindent(io)
	show(io, el.text)
end

#
# Generic Element
#

const Props = Dict{Any,Any} 

struct Element{ns, tag} <: Node 
	children::Vector{Union{TextNode,Element}}
	props::Props
end
Element{ns, tag}() where {ns, tag} = Element{ns,tag}([], Dict())
Element(ns, tag, children, props) = Element{Symbol(ns),Symbol(tag)}(children, props)
Element(ns::Symbol, tag::Symbol, children, props) = Element{ns, tag}(children, props)
Element(ns, tag, children=[], kwargs...) = Element(ns, tag, children, Props(kwargs))
Element(tag, children::AbstractVector=[]; kwargs...) = Element(:xhtml, tag, children, Props(kwargs))

Base.convert(::Type{Vector{Node}}, x::Node) = [x]

function namespace(e::Element{ns}) where ns
	ns
end

Base.length(::TextNode) = 0
Base.length(e::Element) = i + map(Base.length, e.children) |> sum

function Base.show(io::IO, e::Element{ns, tag}) where{ns, tag}
	_showindent(io)
	write(io,"(")
	write(io, namespace(e))
	write(io, ":")
	write(io, tag)
	for (prop, value) in e.props
		write(io, " ")
		write(io, prop)
		write(io,"=")
		show(io, value)
		write(io, "")
	end
	child_io = IOContext(io, :indent => get(io, :indent, 0) + 1)
	for child in e.children
		show(child_io, child)
	end
	write(io, ")");
end

end # module
