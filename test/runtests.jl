using Test

using LightDOM

@testset "Collection" begin
	elem = Element(:xhtml, :body, id="foo")

	@test haskey(elem, :id)
	@test !haskey(elem, :foo)
end

@testset "Testing Node Creation" begin
	@test text("Text Node") == TextNode("Text Node")
	
	elem = Element{:xhtml, :body}()
	# @test elem isa Element
	@test namespace(elem) == :xhtml
	@test tag(elem) == :body

	elem = Element(:div, text("Hello World"))
	@test elem.children[1] isa TextNode
	@test elem.children[1].text == "Hello World"

	elem = Element(:div; width=10, height=10)
	@test haskey(elem.props, :width)
	@test haskey(elem.props, :height)
end
