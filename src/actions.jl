const ACTIONS_DICT = Dict(:north => 1, :east => 2, :south => 3, :west => 4, :tag => 5)
const ACTION_NAMES = Dict(1 => "North", 2 => "East", 3 => "South", 4 => "West", 5 => "Tag")

POMDPs.actions(pomdp::TagPOMDP) = 1:length(ACTIONS_DICT)

function POMDPs.actionindex(pomdp::TagPOMDP, a::Int)
    @assert a in 1:length(ACTIONS_DICT) "Invalid action index"
    return a
end
function POMDPs.actionindex(pomdp::TagPOMDP, a::Symbol)
    @assert a in keys(ACTIONS_DICT) "Invalid action symbol"
    return ACTIONS_DICT[a]
end

"""
    list_actions(pomdp::TagPOMDP)

Prints a list of actions and their symbol (name).
"""
function list_actions(pomdp::TagPOMDP)
    println("Actions:")
    for (name, a) in ACTIONS_DICT
        println("  $a: $name")
    end
end
