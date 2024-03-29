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
    repo = "github.com/JuliaPOMDP/TagPOMDPProblem.jl.git"
)
