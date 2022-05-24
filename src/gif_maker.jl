using Tag
using POMDPGifs
using Random
using QMDP

rng = MersenneTwister(1)
pomdp = TagPOMDP()

policy = solve(QMDPSolver(verbose=true), pomdp)

@show makegif(pomdp, policy; filename="Tag_QMDP.gif", max_steps=50, rng=rng)


# grid = TagGrid(;bottom_grid=(10,3), top_grid=(3,3), top_grid_x_attach_pt=6)
# pomdp = TagPOMDP(;tag_grid=grid)
# policy = solve(QMDPSolver(verbose=true), pomdp)
# @show makegif(pomdp, policy; filename="out.gif", max_steps=25, rng=rng)

# solver = SARSOPSolver(timeout=150)
# policy = solve(solver, pomdp)
