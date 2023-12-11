POMDPs.observations(pomdp::TagPOMDP) = 1:(get_prop(pomdp.mg, :num_grid_pos) + 1)
POMDPs.obsindex(pomdp::TagPOMDP, o::Int) = o

function POMDPs.observation(pomdp::TagPOMDP, a::Int, sp::TagState)
    if sp.r_pos == sp.t_pos
        return Deterministic(observations(pomdp)[end])
    else
        return Deterministic(sp.r_pos)
    end
end
