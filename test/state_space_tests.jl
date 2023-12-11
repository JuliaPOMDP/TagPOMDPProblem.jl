@testset "state space" begin
    pomdp = TagPOMDP()
    state_iterator = states(pomdp)
    ss = ordered_states(pomdp)
    @test length(ss) == length(pomdp)
    @test test_state_indexing(pomdp, ss)

    @test isterminal(pomdp, TagState(0, 0))
    @test stateindex(pomdp, TagState(0, 0)) == length(pomdp)
    @test stateindex(pomdp, TagState(1, 1)) == 1

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

    pomdp = TagPOMDP(; map_str=map_str)
    state_iterator = states(pomdp)
    ss = ordered_states(pomdp)
    @test length(ss) == length(pomdp)
    @test length(pomdp) == 40 * 40 + 1
    @test test_state_indexing(pomdp, ss)
    @test isterminal(pomdp, TagState(0, 0))
    @test !isterminal(pomdp, TagState(23, 12))
    @test has_consistent_initial_distribution(pomdp)

    try # test invalid state
        stateindex(pomdp, TagState(41, 41))
        @test false
    catch
        @test true
    end

    try # test invalid state
        stateindex(pomdp, TagState(0, 1))
        @test false
    catch
        @test true
    end

    try # test invalid state
        stateindex(pomdp, TagState(1, 0))
        @test false
    catch
        @test true
    end

    @test get_prop(pomdp.mg, 1, 2, :action) == :east
    @test get_prop(pomdp.mg, 1, 9, :action) == :south
    @test get_prop(pomdp.mg, 17, 16, :action) == :west
    @test get_prop(pomdp.mg, 20, 14, :action) == :north
end
