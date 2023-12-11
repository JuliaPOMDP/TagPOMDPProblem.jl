using Test
using POMDPs
using POMDPTools
using TagPOMDPProblem
using MetaGraphs
using Graphs

function test_state_indexing(pomdp::TagPOMDP, ss::Vector{TagState})
    for (ii, s) in enumerate(states(pomdp))
        if s != ss[ii]
            return false
        end
    end
    return true
end

@testset verbose=true "All Tests" begin
    include("constructor_tests.jl")
    include("state_space_tests.jl")
    include("action_space_tests.jl")
    include("reward_tests.jl")
    include("observation_tests.jl")
    include("transition_tests.jl")
    include("rendering_tests.jl")
end
