@testset "observations" begin
    map_str = """
    xxoo
    xoox
    oooo
    """
    pomdp = TagPOMDP(; map_str=map_str)
    num_grid_pos = get_prop(pomdp.mg, :num_grid_pos)

    obs = observations(pomdp)
    @test all(obs .== ordered_observations(pomdp))

    for ri in 1:num_grid_pos
        s = TagState(ri, 1)
        for a in actions(pomdp)
            o = observation(pomdp, a, s)
            @test isa(o, Deterministic{Int})
            if ri == 1
                @test o.val == num_grid_pos + 1
            else
                @test o.val == ri
            end
        end
    end

    @test has_consistent_observation_distributions(pomdp)
end
