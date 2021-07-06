import Base: 
	length,
	isempty
	
"""
We treat TextNode as an empty collection. While it might seem like it could act on the text content, this makes
the behaviour of TextNode and Element unexpectedly different.
"""
Base.length(::TextNode) = 1
Base.length(e::Element) = i + map(Base.length, e.children) |> sum

Base.isempty(::TextNode) = true
Base.isempty(e::Element) = isempty(e.children)

"""
I'm tempted to add AbstractArray functions pointing at Element.children, and Dict structures at Element.props,
but that's quite a bit of boilerplate.
Should be able to do it with a macro!
"""

children(e::Element) = e.children
props(e::Element) = e.props

