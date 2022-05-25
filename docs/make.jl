using Documenter

push!(LOAD_PATH, "../src/")

using Documenter, TagPOMDPProblem

makedocs(
    modules = [TagPOMDPProblem],
    format = Documenter.HTML(),
    sitename = "TagPOMDPProblem.jl",

)

deploydocs(
    repo = "github.com/dylan-asmar/TagPOMDPProblem.jl.git"
)
