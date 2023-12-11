@testset "reward" begin
    pomdp = TagPOMDP()
    s = TagState(1, 10)
    for ai in 1:4
        @test reward(pomdp, s, ai) == pomdp.step_penalty
    end
    @test reward(pomdp, s, 5) == pomdp.tag_penalty

    s = TagState(10, 10)
    for ai in 1:4
        @test reward(pomdp, s, ai) == pomdp.step_penalty
    end
    @test reward(pomdp, s, 5) == pomdp.tag_reward

    s = TagState(0, 0)
    for ai in 1:5
        @test reward(pomdp, s, ai) == 0.0
    end
end
