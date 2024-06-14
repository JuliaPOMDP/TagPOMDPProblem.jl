var documenterSearchIndex = {"docs":
[{"location":"#TagPOMDPProblem.jl-Documentation","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"Tag POMDP problem using POMDPs.jl. Original problem was presented in Pineau, Joelle et al. “Point-based value iteration: An anytime algorithm for POMDPs.” IJCAI (2003) (online here).","category":"page"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"The goal of the agent is to tag the opponent by performing the tag action while in the same square as the opponent. The agent can move in the four cardinal directions or perform the tag action. The movement of the agent is deterministic based on its selected action. A reward of step_penalty is imposed for each motion action and the tag action results in a tag_reward for a successful tag and tag_penalty otherwise. The agent’s position is fully observable but the opponent’s position is unobserved unless both actors are in the same cell. The opponent moves stochastically according to a fixed policy away from the agent. The opponent moves away from the agent move_away_probability of the time and stays in the same cell otherwise. The implementation of the opponent’s movement policy varies slightly from the original paper allowing more movement away from the agent, thus making the scenario slightly more challenging. This implementation redistributes the probabilities of actions that result in hitting a wall to other actions that result in moving away. The original transition function is available by passing transition_option=:orig during creation of the problem.","category":"page"},{"location":"#Manual-Outline","page":"TagPOMDPProblem.jl Documentation","title":"Manual Outline","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"","category":"page"},{"location":"#Installation","page":"TagPOMDPProblem.jl Documentation","title":"Installation","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"Use ] to get to the package manager to add the package. ","category":"page"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"julia> ]\npkg> add TagPOMDPProblem","category":"page"},{"location":"#Examples","page":"TagPOMDPProblem.jl Documentation","title":"Examples","text":"","category":"section"},{"location":"#Default-Problem","page":"TagPOMDPProblem.jl Documentation","title":"Default Problem","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"using POMDPs\nusing TagPOMDPProblem\nusing SARSOP # load a  POMDP Solver\nusing POMDPGifs # to make gifs\n\npomdp = TagPOMDP()\nsolver = SARSOPSolver(; timeout=150)\npolicy = solve(solver, pomdp)\nsim = GifSimulator(;\n    filename=\"default.gif\",\n    max_steps=50\n)\nsimulate(sim, pomdp, policy)","category":"page"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"(Image: Tag Example)","category":"page"},{"location":"#Larger-Map","page":"TagPOMDPProblem.jl Documentation","title":"Larger Map","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"using POMDPs\nusing TagPOMDPProblem\nusing SARSOP \nusing POMDPGifs\n\nmap_str = \"\"\"\nxxooooooxxxxxxx\nxxooooooxxxxxxx\nxxooooooxxxxxxx\nxxooooooxxxxxxx\nxxooooooxxxxxxx\nooooooooooooooo\nooooooooooooooo\nooooooooooooooo\nooooooooooooooo\n\"\"\"\npomdp = TagPOMDP(;map_str=map_str)\nsolver = SARSOPSolver(; timeout=600)\npolicy = solve(solver, pomdp)\n\nsim = GifSimulator(;\n    filename=\"larger.gif\",\n    max_steps=50\n)\nsimulate(sim, pomdp, policy)","category":"page"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"(Image: Tag Larger Map Example)","category":"page"},{"location":"#Map-with-Obstacles","page":"TagPOMDPProblem.jl Documentation","title":"Map with Obstacles","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"using POMDPs\nusing TagPOMDPProblem\nusing SARSOP \nusing POMDPGifs\n\nmap_str = \"\"\"\nxxxxxxxxxx\nxoooooooox\nxoxoxxxxox\nxoxoxxxxox\nxoxooooxox\nxoxoxxoxox\nxoxoxxoxox\nxoxoxxoxox\nxoooooooox\nxxxxxxxxxx\n\"\"\"\npomdp = TagPOMDP(;map_str=map_str)\nsolver = SARSOPSolver(; timeout=600)\npolicy = solve(solver, pomdp)\n\nsim = GifSimulator(;\n    filename=\"boundary.gif\",\n    max_steps=50,\n    rng=Random.MersenneTwister(1)\n)\nsimulate(sim, pomdp, policy)","category":"page"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"(Image: Obstacle Map Example)","category":"page"},{"location":"#Exported-Functions","page":"TagPOMDPProblem.jl Documentation","title":"Exported Functions","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"TagPOMDP()\nPOMDPTools.render(::TagPOMDP, ::NamedTuple)\nTagPOMDP\nTagState","category":"page"},{"location":"#TagPOMDPProblem.TagPOMDP-Tuple{}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.TagPOMDP","text":"TagPOMDP(; kwargs...)\n\nReturns a TagPOMDP <: POMDP{TagState, Int, Int}. Default values are from the original paper: Pineau, Joelle et al. “Point-based value iteration: An anytime algorithm for POMDPs.” IJCAI (2003).\n\nThe main difference in this implementation is the use of only 1 terminal state and an opponent transition function that aims to keep the probability of moving away to the specified value if there is a valid action (versus allowing the action and thus increasing the probability of remaining in place). To use the transition function from the original implementation, pass orig_transition_fcn = true.\n\nKeywords\n\nmap_str::String: String representing the map, 'x' for walls, 'o' for open space.   Default is the standard map from the original paper.\nDefault: \"\"\"   xxxxxoooxx\nxxxxxoooxx\nxxxxxoooxx\noooooooooo\noooooooooo\"\"\"\ntag_reward::Float64: Reward for the agent tagging the opponent, default = +10.0\ntag_penalty::Float64: Reward for the agent using the tag action and not being in the same grid cell as the opponent, default = -10.0\nstep_penalty::Float64: Reward for each movement action, default = -1.0\ndiscount_factor::Float64: Discount factor, default = 0.95\nmove_away_probability::Float64: Probability associated with the opponent srategy. This probability is the chance it moves away, default = 0.8\ntransition_option::Symbol: Option for the transition function. Options are :orig and :modified. Default is :modified.\n\n\n\n\n\n","category":"method"},{"location":"#POMDPTools.ModelTools.render-Tuple{TagPOMDP, NamedTuple}","page":"TagPOMDPProblem.jl Documentation","title":"POMDPTools.ModelTools.render","text":"render(pomdp::TagPOMDP, step::NamedTuple; pre_act_text::String=\"\")\n\nRender a TagPOMDP step as a plot. If the step contains a belief, the belief will be plotted using a color gradient of green for the belief of the target position and belief over the robot position will be plotted as an orange robot with a faded robot representing smaller belief. If the step contains a state, the robot and target will be plotted in their respective positions. If the step contains an action, the action will be plotted in the bottom center of the plot. pre_act_text can be used to add text before the action text.\n\npomdp::TagPOMDP: The TagPOMDP to render\nstep::NamedTuple: Step step to render with fields b, s, and a\npre_act_text::String: Text to add before the action text\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.TagPOMDP","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.TagPOMDP","text":"TagPOMDP <: POMDP{TagState, Int, Int}\n\nPOMDP type for the Tag POMDP.\n\nFields\n\nmg::MetaDiGraph: metagraph representing the map\ndist_matrix::Matrix{Float64}: distance matrix for the metagraph\ntag_reward::Float64: reward for the agent tagging the opponent\ntag_penalty::Float64: reward for the agent using the tag action and not being in the same grid cell as the opponent\nstep_penalty::Float64: reward for each movement action (negative = penalty)\ndiscount_factor::Float64: discount factor\nmove_away_probability::Float64: probability associated with the opponent srategy. This probability is the chance it moves away versus stays in place.\ntransition_option::Symbol: option for the transition function\n\n\n\n\n\n","category":"type"},{"location":"#TagPOMDPProblem.TagState","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.TagState","text":"TagState\n\nRepresents the state in a TagPOMDP problem.\n\nFields\n\nr_pos::Int: vertex of graph representing the position of the robot\nt_pos::Int: vertex of graph representing the position of the target\n\n\n\n\n\n","category":"type"},{"location":"#Internal-Functions","page":"TagPOMDPProblem.jl Documentation","title":"Internal Functions","text":"","category":"section"},{"location":"","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.jl Documentation","text":"TagPOMDPProblem.list_actions(::TagPOMDP)\nTagPOMDPProblem.create_metagraph_from_map(::String)\nTagPOMDPProblem.map_str_from_metagraph(::TagPOMDP)\nTagPOMDPProblem.state_from_index(::TagPOMDP, ::Int)\nTagPOMDPProblem.modified_transition(::TagPOMDP, ::TagState, ::Int)\nTagPOMDPProblem.orig_transition(::TagPOMDP, ::TagState, ::Int)\nTagPOMDPProblem.move_direction(::TagPOMDP, ::Int, ::Int)","category":"page"},{"location":"#TagPOMDPProblem.list_actions-Tuple{TagPOMDP}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.list_actions","text":"list_actions(pomdp::TagPOMDP)\n\nPrints a list of actions and their symbol (name).\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.create_metagraph_from_map-Tuple{String}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.create_metagraph_from_map","text":"create_metagraph_from_map(map_str::String)\n\nReturns a MetaDiGraph representing the map. 'x' for walls, 'o' for open space.\n\nProperties of the graph:\n\n:nrows: number of rows in the map\n:ncols: number of columns in the map\n:num_grid_pos: number of open spaces in the map\n:node_mapping: dictionary mapping (i, j) position in the map to node number\n:node_pos_mapping: dictionary mapping node number to (i, j) position in the map\n\nProperties of the edges:\n\n:action: action associated with the edge (e.g. :north, :south, :east, :west)\n\nExample mat_str for the original TagPOMDP (the one in the original paper)\n\nxxxxxoooxx\n\nxxxxxoooxx\n\nxxxxxoooxx\n\noooooooooo\n\noooooooooo\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.map_str_from_metagraph-Tuple{TagPOMDP}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.map_str_from_metagraph","text":"map_str_from_metagraph(pomdp::TagPOMDP)\n\nReturns a string representing the map. 'x' for walls, 'o' for open space. Uses the node_mapping property of the metagraph to determine which nodes are open spaces.\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.state_from_index-Tuple{TagPOMDP, Int64}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.state_from_index","text":"state_from_index(pomdp::TagPOMDP, si::Int)\n\nReturn the state corresponding to the given index.\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.modified_transition-Tuple{TagPOMDP, TagState, Int64}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.modified_transition","text":"modified_transition(pomdp::TagPOMDP, s::TagState, a::Int)\n\nModified transition function for the TagPOMDP. This transition is similar to the original paper but differs with how it redistributes the probabilities of actions where the opponent would hit a wall and stay in place. The original implementation redistributed those probabilities to the stay in place state. This implementation keeps the probability of moving away from the agent at the defined threshold if there is a valid movement option (away and not into a wall). The movement of the agent is deterministic in the direction of the action.\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.orig_transition-Tuple{TagPOMDP, TagState, Int64}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.orig_transition","text":"orig_transition(pomdp::TagPOMDP, s::TagState, a::Int)\n\nAlternative transition function for the TagPOMDP. This transition is mimics the original paper. The move away probability is split equally between north/south and east/west pairs. If a move results in moving \"away\" from the agent while ignoring walls, that move is still considered valid. This results in the the agent hitting a wall and staying in place...thus increasing the probability of staying in place.\n\n\n\n\n\n","category":"method"},{"location":"#TagPOMDPProblem.move_direction-Tuple{TagPOMDP, Int64, Int64}","page":"TagPOMDPProblem.jl Documentation","title":"TagPOMDPProblem.move_direction","text":"move_direction(pomdp::TagPOMDP, v::Int, a::Int)\n\nMove the robot in the direction of the action. Finds the neighbors of the current node and checks if the action is valid (edge with corresponding action exists). If so, returns the node index of the valid action.\n\n\n\n\n\n","category":"method"}]
}