using Test

using LightDOM

@testset "Testing Node Creation" begin
	@test text("Text Node") == TextNode("Text Node")
	@test Element{:xhtml, :body}
	@test Element(:div, text("Hello World"))
end
