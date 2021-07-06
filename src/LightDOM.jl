module LightDOM

import Base: convert,
	length,
	push!

export 	Node,
	TextNode,
	Element,
	text,
	count,
	children,
	props


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

include("show.jl")
include("collection.jl")

end # module
