POMDPs.states(pomdp::TagPOMDP) = pomdp

function Base.iterate(pomdp::TagPOMDP, ii::Int=1)
    if ii > length(pomdp)
        return nothing
    end
    s = state_from_index(pomdp, ii)
    return (s, ii + 1)
end

"""
    state_from_index(pomdp::TagPOMDP, si::Int)

Return the state corresponding to the given index.
"""
function state_from_index(pomdp::TagPOMDP, si::Int)
    @assert si <= length(pomdp) "Index out of bounds"
    @assert si > 0 "Index out of bounds"
    if si == length(pomdp)
        return TagState(0, 0)
    end
    num_grid_pos = get_prop(pomdp.mg, :num_grid_pos)
    r_pos, t_pos = Tuple(CartesianIndices((num_grid_pos, num_grid_pos))[si])
    return TagState(r_pos, t_pos)
end

function POMDPs.stateindex(pomdp::TagPOMDP, s::TagState)
    if isterminal(pomdp, s)
        return length(pomdp)
    end
    num_grid_pos = get_prop(pomdp.mg, :num_grid_pos)
    @assert s.r_pos > 0 && s.r_pos <= num_grid_pos "Invalid robot position"
    @assert s.t_pos > 0 && s.t_pos <= num_grid_pos "Invalid target position"

    si = LinearIndices((num_grid_pos, num_grid_pos))[s.r_pos, s.t_pos]
    return si
end

# Uniform over the entire state space except the terminal state
function POMDPs.initialstate(pomdp::TagPOMDP)
    probs = normalize(ones(length(pomdp) - 1), 1)
    return SparseCat(ordered_states(pomdp)[1:end - 1], probs)
end
