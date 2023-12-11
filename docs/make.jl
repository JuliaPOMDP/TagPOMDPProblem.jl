using Documenter

push!(LOAD_PATH, "../src/")

using Documenter, TagPOMDPProblem, POMDPTools

makedocs(
    sitename = "TagPOMDPProblem.jl",
    authors="Dylan Asmar",
    modules = [TagPOMDPProblem],
    format = Documenter.HTML(),
    doctest=false,
    checkdocs=:exports
)

deploydocs(
    repo = "github.com/dylan-asmar/TagPOMDPProblem.jl.git"
)
