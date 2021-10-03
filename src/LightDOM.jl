module LightDOM

import Base: convert,
	length,
	push!

export 	Node,
	TextNode,
	Element,
	text,
	count,
	namespace,
	tag,
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

"""
	Namespace and tag are part of the type (rather than a prop) to allow
	dispatch to provide overrides of methods for specific namespaces/tags
"""
struct Element{ns, tag} <: Node
	children::Vector{Union{TextNode,Element}}
	props::Props
end
Element{ns, tag}() where {ns, tag} = Element{ns,tag}([], Dict())
Element(ns::Symbol, tag::Symbol, children, props) = Element{ns, tag}(children, props)
Element(ns::Symbol, tag::Symbol, children=[]; kwargs...) = Element(ns, tag, children, Props(kwargs))
Element(tag::Symbol, children::AbstractVector=[]; kwargs...) = Element(:nothing, tag, children, Props(kwargs))
Element(tag::Symbol, textContent::AbstractString; kwargs...) = Element(:nothing, tag, text(textContent), Props(kwargs))
Element(tag::Symbol, child::Node; kwargs...) = Element(:nothing, tag, child, Props(kwargs))

Base.convert(::Type{Vector{Union{TextNode,Element}}}, x::Node) = Vector{Union{TextNode,Element}}([x])

function namespace(e::Element{ns}) where ns
	ns
end
function tag(e::Element{ns,t}) where {ns, t}
	t
end

include("show.jl")
include("collection.jl")

end # module
