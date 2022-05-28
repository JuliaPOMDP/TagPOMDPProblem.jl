using Documenter

push!(LOAD_PATH, "../src/")

using Documenter, TagPOMDPProblem

makedocs(
    sitename = "TagPOMDPProblem.jl",
    authors="Dylan Asmar",
    modules = [TagPOMDPProblem],
    format = Documenter.HTML(),


)

deploydocs(
    repo = "github.com/dylan-asmar/TagPOMDPProblem.jl.git",
    devbranch = "dev",
)
