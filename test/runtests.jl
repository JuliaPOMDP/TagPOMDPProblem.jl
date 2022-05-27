using Test
using Random
using POMDPs
using POMDPModelTools
using POMDPTesting
using TagPOMDPProblem
using SparseArrays

function test_state_indexing(pomdp::TagPOMDP, ss::Vector{TagState})
    for (ii, s) in enumerate(states(pomdp))
        if s != ss[ii]
            return false
        end
    end
    return true
end

function pos_to_obs_std(pos::Tuple{Int, Int})
    if pos[2] < 3
        return pos[1] + (pos[2] - 1) * 10
    elseif pos[2] == 3
        return 20 + pos[1] - 5
    elseif pos[2] == 4
        return 23 + pos[1] - 5
    else
        return 26 + pos[1] - 5
    end
end

@testset verbose=true "All Tests" begin

    @testset "state space" begin
        pomdp = TagPOMDP()
        state_iterator = states(pomdp)
        ss = ordered_states(pomdp)
        @test length(ss) == length(pomdp)
        @test test_state_indexing(pomdp, ss)
        grid = TagGrid(; bottom_grid=(12, 4), top_grid=(5, 7), top_grid_x_attach_pt=2)
        pomdp = TagPOMDP(; tag_grid=grid)
        state_iterator = states(pomdp)
        ss = ordered_states(pomdp)
        @test length(ss) == length(pomdp)
        @test test_state_indexing(pomdp, ss)
        terminal_state = TagState((1, 1), (5, 1), true)
        @test isterminal(pomdp, terminal_state)
        not_terminal = TagState((1, 1), (5, 1), false)
        @test !isterminal(pomdp, not_terminal)
        @test discount(pomdp) == 0.95
        pomdp = TagPOMDP(; discount_factor=0.5)
        @test discount(pomdp) == 0.5
        @test has_consistent_initial_distribution(pomdp)
    end

    @testset "action space" begin
        pomdp = TagPOMDP()
        acts = actions(pomdp)
        @test acts == ordered_actions(pomdp)
        @test length(acts) == length(actions(pomdp))
        @test length(acts) == 5
        s = TagState((1, 2), (2, 2), false)
        @test actions(pomdp, s) == actions(pomdp)
        s2 = TagState((1, 2), (2, 2), true)
        @test actions(pomdp, s2) == actions(pomdp)
        @test actionindex(pomdp, 1) == 1
        for (ii, ai) in enumerate(actions(pomdp))
            @test actionindex(pomdp, ai) == ii
        end
    end

    @testset "transition" begin
        rng = MersenneTwister(1)
        pomdp = TagPOMDP()

        @test has_consistent_transition_distributions(pomdp)

        s0 = TagState((6, 2), (6, 2), false)
        r_pos = [(6, 3), (7, 2), (6, 1), (5, 2), (0, 0)]
        t_pos = [(6, 3), (7, 2), (6, 1), (5, 2), (0, 0)]
        for ai in actions(pomdp)
            d = transition(pomdp, s0, ai)
            if ai != 5
                @test all([d.vals[ii].r_pos == r_pos[ai] for ii in 1:length(d.vals)])
                @test all([isapprox(d.probs[ii], 0.2; atol=1e-10) for ii in 1:length(d.probs)])
                for ti in 1:4
                    @test any([d.vals[ii].t_pos == t_pos[ti] for ii in 1:length(d.vals)])
                end
            else
                @test d.val.r_pos == r_pos[ai]
                @test d.val.t_pos == t_pos[ai]
                @test isa(d, Deterministic{TagState})
                sp = rand(rng, d)
                @test isterminal(pomdp, sp)
            end
        end

        s0 = TagState((1, 1), (10, 2), false)
        r_pos = [(1, 2), (2, 1), (1, 1), (1,1), (1, 1)]
        t_pos = [(10, 2)]
        for ai in actions(pomdp)
            d = transition(pomdp, s0, ai)
            @test all([d.vals[ii].r_pos == r_pos[ai] for ii in 1:length(d.vals)])
            @test all([isapprox(d.probs[ii], 1.0; atol=1e-10) for ii in 1:length(d.probs)])
            for ti in 1:length(t_pos)
                @test any([d.vals[ii].t_pos == t_pos[ti] for ii in 1:length(d.vals)])
            end
        end

        s0 = TagState((1, 2), (10, 2), false)
        r_pos = [(1, 2), (2, 2), (1, 1), (1, 2), (1, 2)]
        t_pos = [(10, 2), (10, 1)]
        probs = [0.2, 0.8]
        for ai in actions(pomdp)
            d = transition(pomdp, s0, ai)
            @test all([d.vals[ii].r_pos == r_pos[ai] for ii in 1:length(d.vals)])
            for ti in 1:length(t_pos)
                tx_bools = [d.vals[ii].t_pos == t_pos[ti] for ii in 1:length(d.vals)]
                @test any(tx_bools)
                @test isapprox(d.probs[tx_bools]..., probs[ti]; atol=1e-10)
            end
        end

        s0 = TagState((10, 2), (1, 2), false)
        r_pos = [(10, 2), (10, 2), (10, 1), (9, 2), (10, 2)]
        t_pos = [(1, 2), (1, 1)]
        probs = [0.2, 0.8]
        for ai in actions(pomdp)
            d = transition(pomdp, s0, ai)
            @test all([d.vals[ii].r_pos == r_pos[ai] for ii in 1:length(d.vals)])
            for ti in 1:length(t_pos)
                tx_bools = [d.vals[ii].t_pos == t_pos[ti] for ii in 1:length(d.vals)]
                @test any(tx_bools)
                @test isapprox(d.probs[tx_bools]..., probs[ti]; atol=1e-10)
            end
        end

        s0 = TagState((1, 1), (2, 2), true)
        d = transition(pomdp, s0, 1)
        @test isa(d, Deterministic{TagState})
        sp = rand(rng, d)
        @test isterminal(pomdp, sp)
    end

    @testset "observations" begin
        rng = MersenneTwister(1)
        pomdp = TagPOMDP()

        obs = observations(pomdp)
        @test obs == ordered_observations(pomdp)

        s0 = TagState((1, 1), (1, 1), false)
        @test observation(pomdp, 1, s0).probs[30] == 1.0
        s0 = TagState((1, 1), (1, 2), false)
        @test observation(pomdp, 1, s0).probs[1] == 1.0
        s0 = TagState((10, 1), (1, 2), false)
        @test observation(pomdp, 1, s0).probs[10] == 1.0
        s0 = TagState((8, 5), (1, 2), false)
        @test observation(pomdp, 1, s0).probs[29] == 1.0

        d = initialstate(pomdp)
        bool_vec = zeros(500)
        for ii = 1:500
            s = rand(rng, d)
            if s.r_pos == s.t_pos
                bool_vec[ii] = all([observation(pomdp, ai, s).probs[30] == 1.0 for ai in 1:5])
            else
                obs_idx = pos_to_obs_std(s.r_pos)
                bool_vec[ii] = all([observation(pomdp, ai, s).probs[obs_idx] == 1.0 for ai in 1:5])
            end
        end
        @test all(bool_vec .== 1.0)

        @test has_consistent_observation_distributions(pomdp)
    end

    @testset "reward" begin
        pomdp = TagPOMDP()
        s0 = TagState((1, 1), (10, 2), false)
        for ai in 1:4
            @test reward(pomdp, s0, ai) == pomdp.step_penalty
        end
        @test reward(pomdp, s0, 5) == pomdp.tag_penalty

        s0 = TagState((10, 2), (10, 2), false)
        for ai in 1:4
            @test reward(pomdp, s0, ai) == pomdp.step_penalty
        end
        @test reward(pomdp, s0, 5) == pomdp.tag_reward

        s0 = TagState((10, 2), (10, 2), true)
        for ai in 1:5
            @test reward(pomdp, s0, ai) == 0.0
        end

        s0 = TagState((0, 0), (0, 0), true)
        for ai in 1:5
            @test reward(pomdp, s0, ai) == 0.0
        end
    end

    @testset "rendering" begin
        pomdp = TagPOMDP()
        render(pomdp)
        s0 = TagState((2, 2), (4, 2), false)
        render(pomdp, (s=s0, a=2))
        b0 = initialstate(pomdp)
        render(pomdp, (s=s0, a=3, b=b0))
        s0 = TagState((2, 2), (2, 2), false)
        render(pomdp, (s=s0, a=4))

        b_vec = zeros(length(pomdp))
        inds = rand(1:(length(pomdp)-1), 10)
        b_vec[inds] .= 1/10
        b_sparse = sparsevec(b_vec)
        render(pomdp, (b=b_sparse,))

    end

    @testset "constructor" begin
        @test TagGrid() isa TagGrid
        @test TagGrid(; bottom_grid = (15, 4), top_grid=(6, 6)) isa TagGrid
        @test TagPOMDP() isa TagPOMDP
        @test TagPOMDP(; tag_reward=20.0, tag_grid=TagGrid()) isa TagPOMDP
    end

end
