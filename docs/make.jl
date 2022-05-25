using Documenter

push!(LOAD_PATH, "../src/")

using Documenter, Tag

makedocs(
    modules = [Tag],
    format = Documenter.HTML(),
    sitename = "Tag.jl",

)

deploydocs(
    repo = "github.com/dylan-asmar/Tag.jl.git"
)
