@testset "action space" begin
    pomdp = TagPOMDP()
    acts = actions(pomdp)

    TagPOMDPProblem.list_actions(pomdp)

    @test all(acts .== ordered_actions(pomdp))
    @test length(acts) == length(actions(pomdp))
    @test length(acts) == 5

    s = TagState(1, 2)
    @test actions(pomdp, s) == actions(pomdp)

    s2 = TagState(2, 13)
    @test actions(pomdp, s2) == actions(pomdp)

    @test actionindex(pomdp, 1) == 1
    for (ii, ai) in enumerate(actions(pomdp))
        @test actionindex(pomdp, ai) == ii
    end

    try # test invalid action
        actionindex(pomdp, 6)
        @test false
    catch
        @test true
    end

    @test actionindex(pomdp, :north) == 1
    @test actionindex(pomdp, :tag) == 5
    try # test invalid action
        actionindex(pomdp, :invalid)
        @test false
    catch
        @test true
    end
end
