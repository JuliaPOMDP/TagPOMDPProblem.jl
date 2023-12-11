@testset "transition" begin
    pomdp = TagPOMDP()

    @test has_consistent_transition_distributions(pomdp)

    map_str = """
    ooo
    ooo
    ooo
    """

    # Test transition function with the default transition option (modified)
    pomdp = TagPOMDP(; map_str=map_str, transition_option=:modified)

    td = transition(pomdp, TagState(5, 5), 1)
    @test all([s.r_pos == 2 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 2)
    @test all([s.r_pos == 6 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 3)
    @test all([s.r_pos == 8 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 4)
    @test all([s.r_pos == 4 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 5)
    @test isa(td, Deterministic{TagState})
    @test isterminal(pomdp, td.val)

    td = transition(pomdp, TagState(2, 5), 2)
    @test length(td.vals) == 4
    @test sum(td.probs) == 1.0
    @test all([s.r_pos == 3 for s in td.vals])
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 5
            @test isapprox(td.probs[ii], pomdp.move_away_probability/3; atol=1e-6)
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability; atol=1e-6)
        end
    end

    td = transition(pomdp, TagState(5, 6), 5)
    @test all([s.r_pos == 5 for s in td.vals])
    @test length(td.vals) == 3
    @test sum(td.probs) == 1.0
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 6
            @test isapprox(td.probs[ii], pomdp.move_away_probability/2; atol=1e-6)
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability; atol=1e-6)
        end
    end

    # Test original paper transition function
    pomdp = TagPOMDP(; map_str=map_str, transition_option=:orig)

    td = transition(pomdp, TagState(5, 5), 1)
    @test all([s.r_pos == 2 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 2)
    @test all([s.r_pos == 6 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 3)
    @test all([s.r_pos == 8 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 4)
    @test all([s.r_pos == 4 for s in td.vals])

    td = transition(pomdp, TagState(5, 5), 5)
    @test isa(td, Deterministic{TagState})
    @test isterminal(pomdp, td.val)

    td = transition(pomdp, TagState(2, 5), 2)
    @test length(td.vals) == 4
    @test sum(td.probs) == 1.0
    @test all([s.r_pos == 3 for s in td.vals])
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 5
            if s.t_pos == 8
                @test isapprox(td.probs[ii], pomdp.move_away_probability/2; atol=1e-6)
            else
                @test isapprox(td.probs[ii], pomdp.move_away_probability/2/2; atol=1e-6)
            end
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability; atol=1e-6)
        end
    end

    td = transition(pomdp, TagState(5, 6), 5)
    @test all([s.r_pos == 5 for s in td.vals])
    @test length(td.vals) == 3
    @test sum(td.probs) == 1.0
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 6
            @test isapprox(td.probs[ii], pomdp.move_away_probability/2/2; atol=1e-6)
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability/2; atol=1e-6)
        end
    end

    map_str = """
    xoxo
    ooxo
    xoxo
    """
    pomdp = TagPOMDP(; map_str=map_str, transition_option=:modified)

    td = transition(pomdp, TagState(1, 2), 4)
    @test length(td.vals) == 2
    @test all([s.r_pos == 1 for s in td.vals])
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 2
            @test s.t_pos == 5
            @test isapprox(td.probs[ii], pomdp.move_away_probability; atol=1e-6)
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability; atol=1e-6)
        end
    end

    td = transition(pomdp, TagState(6, 4), 1)
    @test length(td.vals) == 3
    @test all([s.r_pos == 4 for s in td.vals])
    for (ii, s) in enumerate(td.vals)
        if s.t_pos != 4
            @test (s.t_pos == 1 || s.t_pos == 3)
            @test isapprox(td.probs[ii], pomdp.move_away_probability/2; atol=1e-6)
        else
            @test isapprox(td.probs[ii], 1.0 - pomdp.move_away_probability; atol=1e-6)
        end
    end
end
