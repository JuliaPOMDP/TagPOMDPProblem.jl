using Pkg
Pkg.add("SARSOP")
Pkg.add("POMDPGifs")
Pkg.add("Random")

using POMDPs
using TagPOMDPProblem
using SARSOP
using POMDPGifs
using Random

pomdp = TagPOMDP()
solver = SARSOPSolver(; timeout=150)
policy = solve(solver, pomdp)
sim = GifSimulator(;
    filename="default.gif",
    max_steps=50,
    rng=Random.MersenneTwister(1)
)
simulate(sim, pomdp, policy)
mv("default.gif", "gifs/default.gif")

map_str = """
xxooooooxxxxxxx
xxooooooxxxxxxx
xxooooooxxxxxxx
xxooooooxxxxxxx
xxooooooxxxxxxx
ooooooooooooooo
ooooooooooooooo
ooooooooooooooo
ooooooooooooooo
"""
pomdp = TagPOMDP(;map_str=map_str)
solver = SARSOPSolver(; timeout=600)
policy = solve(solver, pomdp)

sim = GifSimulator(;
    filename="larger.gif",
    max_steps=50,
    rng=Random.MersenneTwister(1)
)
simulate(sim, pomdp, policy)
mv("larger.gif", "gifs/larger.gif")

map_str = """
xxxxxxxxxx
xoooooooox
xoxoxxxxox
xoxoxxxxox
xoxooooxox
xoxoxxoxox
xoxoxxoxox
xoxoxxoxox
xoooooooox
xxxxxxxxxx
"""
pomdp = TagPOMDP(;map_str=map_str)
solver = SARSOPSolver(; timeout=600)
policy = solve(solver, pomdp)

sim = GifSimulator(;
    filename="boundary.gif",
    max_steps=50,
    rng=Random.MersenneTwister(1)
)
simulate(sim, pomdp, policy)
mv("boundary.gif", "gifs/boundary.gif")

Pkg.rm("SARSOP")
Pkg.rm("POMDPGifs")
Pkg.rm("Random")
