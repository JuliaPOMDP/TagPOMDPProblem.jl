@testset "rendering" begin
    map_str = """
    xoxo
    ooxo
    xoxo
    """
    pomdp = TagPOMDP(map_str=map_str)
    render(pomdp)
    s0 = TagState(2, 4)
    render(pomdp, (s=s0, a=2))
    b0 = initialstate(pomdp)
    render(pomdp, (s=s0, a=3, b=b0))
    s0 = TagState(3, 3)
    render(pomdp, (s=s0, a=4))
    render(pomdp, (s=s0, a=5); pre_act_text="Pre-Action Text ")

    s1 = TagState(1, 2)
    s2 = TagState(2, 3)
    s3 = TagState(1, 5)
    s4 = TagState(1, 7)
    render(pomdp, (b=SparseCat([s1, s2, s3, s4], [0.1, 0.2, 0.3, 0.4]), a=4))

    # Test belief vector rendering
    b = zeros(length(pomdp))
    b[2] = 0.1
    b[10] = 0.3
    b[end-10] = 0.4
    b[end-1] = 0.2
    render(pomdp, (b=b,))

    # Test rendering with DiscreteBelief
    b_db = DiscreteBelief(pomdp, ordered_states(pomdp), b)
    render(pomdp, (b=b_db,))

    # Test error handling with invalid belief vector
    try
        b = zeros(length(pomdp) - 2)
        b[2] = 0.5
        b[3] = 0.5
        render(pomdp, (b=b,))
        @test false
    catch
        @test true
    end
end
