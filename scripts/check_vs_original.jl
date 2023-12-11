"""
This script compares this implementation of the Tag POMDP with the original implementation
performance using SARSOP. The original implementation is available at:
https://bigbird.comp.nus.edu.sg/pmwiki/farm/appl/index.php?n=Main.Repository
"""

using Pkg
Pkg.add("SARSOP")
Pkg.add("StatsBase")
Pkg.add("ProgressMeter")

using POMDPs
using POMDPTools
using TagPOMDPProblem
using SARSOP
using StatsBase
using ProgressMeter

sarsop_timeout = 5
num_sims = 5000

pomdp = TagPOMDP(; transition_option=:orig)
solver = SARSOPSolver(; timeout=sarsop_timeout)
policy = solve(solver, pomdp)

sim = RolloutSimulator(; max_steps=50)

rewards = []
@showprogress dt=1 desc="Running simulations..." for ii in 1:num_sims
    r = simulate(sim, pomdp, policy)
    push!(rewards, r)
end

# Print out the mean and 95% confidence interval
println("Original SARSOP performance: $(-6.13) +/- $(0.12)")
println("Reward (w/ 95% CI): $(mean(rewards)) +/- $(1.96 * std(rewards) / sqrt(length(rewards)))")

Pkg.rm("SARSOP")
Pkg.rm("StatsBase")
Pkg.rm("ProgressMeter")
