"""
    POMDPs.transition(pomdp::TagPOMDP, s::TagState, a::Int)

Transition function for the TagPOMDP.
"""
function POMDPs.transition(pomdp::TagPOMDP, s::TagState, a::Int)
    if isterminal(pomdp, s)
        return Deterministic(pomdp.terminal_state)
    end

    if pomdp.transition_option == :orig
        return orig_transition(pomdp, s, a)
    elseif pomdp.transition_option == :modified
        return modified_transition(pomdp, s, a)
    else
        return error("Invalid transition option. $(pomdp.transition_option) is not implemented.")
    end
end

"""
    modified_transition(pomdp::TagPOMDP, s::TagState, a::Int)

Modified transition function for the TagPOMDP. This transition is similar to the original
paper but differs with how it redistributes the probabilities of actions where the
opponent would hit a wall and stay in place. The original implementation redistributed
those probabilities to the stay in place state. This implementation keeps the
probability of moving away from the agent at the defined threshold if there is a valid
movement option (away and not into a wall). The movement of the agent is deterministic
in the direction of the action.
"""
function modified_transition(pomdp::TagPOMDP, s::TagState, a::Int)
    # Check if tagged first. If so, move to the terminal state
    if a == ACTIONS_DICT[:tag]
        if s.r_pos == s.t_pos
            return Deterministic(TagState(0, 0))
        end
    end

    # Robot position is deterministic
    r_pos′ = move_direction(pomdp, s.r_pos, a)

    # Find nodes that are within one step of the target from the graph
    target_neighbors = neighbors(pomdp.mg, s.t_pos)

    # Distance from the target neighbors to the robot position on the graph
    target_neigh_to_robot_dist = pomdp.dist_matrix[s.r_pos, target_neighbors]
    current_dist = pomdp.dist_matrix[s.r_pos, s.t_pos]

    max_dist = max(maximum(target_neigh_to_robot_dist), current_dist)
    t_move_pos_options = target_neighbors[target_neigh_to_robot_dist .>= max_dist]

    # If there are no valid moves, stay in place
    if length(t_move_pos_options) == 0
        return Deterministic(TagState(r_pos′, s.t_pos))
    end

    # Create the transition probability array
    t_probs = ones(length(t_move_pos_options) + 1)
    t_probs[1:end-1] .= pomdp.move_away_probability / length(t_move_pos_options)

    # Add the stay in place probability
    push!(t_move_pos_options, s.t_pos)
    t_probs[end] = 1.0 - pomdp.move_away_probability

    new_states = Vector{TagState}(undef, length(t_move_pos_options))
    for (ii, t_pos′) in enumerate(t_move_pos_options)
        new_states[ii] = TagState(r_pos′, t_pos′)
    end
    return SparseCat(new_states, t_probs)
end

"""
    orig_transition(pomdp::TagPOMDP, s::TagState, a::Int)

Alternative transition function for the TagPOMDP. This transition is mimics the original
paper. The move away probability is split equally between north/south and east/west pairs.
If a move results in moving "away" from the agent while ignoring walls, that move is still
considered valid. This results in the the agent hitting a wall and staying in place...thus
increasing the probability of staying in place.
"""
function orig_transition(pomdp::TagPOMDP, s::TagState, a::Int)
    # Check if tagged first. If so, move to the terminal state
    if a == ACTIONS_DICT[:tag]
        if s.r_pos == s.t_pos
            return Deterministic(TagState(0, 0))
        end
    end

    # Robot position is deterministic
    r_pos′ = move_direction(pomdp, s.r_pos, a)

    # Find nodes that are within one step of the target from the graph
    target_neighbors = neighbors(pomdp.mg, s.t_pos)

    # Distance from the target neighbors to the robot position on the graph
    target_neigh_to_robot_dist = pomdp.dist_matrix[s.r_pos, target_neighbors]
    current_dist = pomdp.dist_matrix[s.r_pos, s.t_pos]

    max_dist = max(maximum(target_neigh_to_robot_dist), current_dist)
    t_move_pos_options = target_neighbors[target_neigh_to_robot_dist .>= max_dist]

    # If there are no valid moves, stay in place
    if length(t_move_pos_options) == 0
        return Deterministic(TagState(r_pos′, s.t_pos))
    end

    # Move directions for the move options
    t_move_dirs = [get_prop(pomdp.mg, s.t_pos, t_pos′, :action) for t_pos′ in t_move_pos_options]

    # Isolate ns and ew moves
    ns_moves = t_move_pos_options[(t_move_dirs .== :north) .|| (t_move_dirs .== :south)]
    ew_moves = t_move_pos_options[(t_move_dirs .== :east) .|| (t_move_dirs .== :west)]


    robot_map_coord = get_prop(pomdp.mg, :node_pos_mapping)[s.r_pos]
    target_map_coord = get_prop(pomdp.mg, :node_pos_mapping)[s.t_pos]

    # Check if moving in each direction would result in moving away from the target
    # ignoring walls and only considering map coordinates
    north_move_away = robot_map_coord[1] >= target_map_coord[1]
    south_move_away = robot_map_coord[1] <= target_map_coord[1]
    east_move_away = robot_map_coord[2] <= target_map_coord[2]
    west_move_away = robot_map_coord[2] >= target_map_coord[2]

    ns_away = north_move_away + south_move_away
    ew_away = east_move_away + west_move_away

    if ns_away == 0
        ns_probs = 0.0
    else
        ns_probs = pomdp.move_away_probability / 2 / ns_away
    end

    if ew_away == 0
        ew_probs = 0.0
    else
        ew_probs = pomdp.move_away_probability / 2 / ew_away
    end

    # Create the transition probability array
    t_probs = zeros(length(t_move_pos_options) + 1)
    if length(ns_moves) > 0
        t_probs[1:length(ns_moves)] .= ns_probs
    end
    if length(ew_moves) > 0
        t_probs[length(ns_moves)+1:(length(ns_moves) + length(ew_moves))] .= ew_probs
    end

    # Add the stay in place probability
    push!(t_move_pos_options, s.t_pos)
    t_probs[end] = 1.0 - sum(t_probs[1:end-1])

    new_states = Vector{TagState}(undef, length(t_move_pos_options))

    ii = 0
    for t_pos′ in ns_moves
        ii += 1
        new_states[ii] = TagState(r_pos′, t_pos′)
    end
    for t_pos′ in ew_moves
        ii += 1
        new_states[ii] = TagState(r_pos′, t_pos′)
    end
    new_states[end] = TagState(r_pos′, s.t_pos)

    return SparseCat(new_states, t_probs)

end

"""
    move_direction(pomdp::TagPOMDP, v::Int, a::Int)

Move the robot in the direction of the action. Finds the neighbors of the current node
and checks if the action is valid (edge with corresponding action exists). If so, returns
the node index of the valid action.
"""
function move_direction(pomdp::TagPOMDP, v::Int, a::Int)
    neighs = neighbors(pomdp.mg, v)
    for n_i in neighs
        if ACTIONS_DICT[get_prop(pomdp.mg, v, n_i, :action)] == a
            return n_i
        end
    end
    return v
end
