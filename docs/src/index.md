# TagPOMDPProblem.jl Documentation

Tag POMDP problem using [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl). Original problem was presented in Pineau, Joelle et al. “Point-based value iteration: An anytime algorithm for POMDPs.” IJCAI (2003) ([online here](https://www.ijcai.org/Proceedings/03/Papers/147.pdf)).

The goal of the agent is to tag the opponent by performing the tag action while in the same square as the opponent. The agent can move in the four cardinal directions or perform the tag action. The movement of the agent is deterministic based on its selected action. A reward of `step_penalty` is imposed for each motion action and the tag action results in a `tag_reward` for a successful tag and `tag_penalty` otherwise. The agent’s position is fully observable but the opponent’s position is unobserved unless both actors are in the same cell. The opponent moves stochastically according to a fixed policy away from the agent. The opponent moves away from the agent `move_away_probability` of the time and stays in the same cell otherwise. The implementation of the opponent’s movement policy varies slightly from the original paper allowing more movement away from the agent, thus making the scenario slightly more challenging. This implementation redistributes the probabilities of actions that result in hitting a wall to other actions that result in moving away. The original transition function is available by passing `orig_transition_fcn = true` during creation of the problem.

```@docs
TagPOMDP()
TagGrid()
TagState
TagPOMDP
TagGrid
```