@testset "Constructor" begin
    @test TagPOMDP() isa TagPOMDP
    @test TagPOMDP(; tag_reward=20.0) isa TagPOMDP
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
    @test TagPOMDP(; map_str=map_str) isa TagPOMDP
    display(TagPOMDP(; map_str=map_str))
    @test discount(TagPOMDP()) == 0.95
    @test discount(TagPOMDP(; discount_factor=0.5)) == 0.5

    map_str = """xxx\nxox\nxyx\nooo"""
    try # test invalid map
        TagPOMDP(; map_str=map_str)
        @test false
    catch
        @test true
    end

    map_str = """xox\noxo\nooo\nxxx"""
    pomdp = TagPOMDP(; map_str=map_str)
    @test get_prop(pomdp.mg, :nrows) == 4
    @test get_prop(pomdp.mg, :ncols) == 3
    @test get_prop(pomdp.mg, :num_grid_pos) == 6
    @test ne(pomdp.mg) == 8
    @test pomdp.dist_matrix[1, 1] == 0.0
    @test isinf(pomdp.dist_matrix[1, 2])
    @test isinf(pomdp.dist_matrix[1, 3])
    @test isinf(pomdp.dist_matrix[4, 1])
    @test pomdp.dist_matrix[4, 3] == 3.0

    @test get_prop(pomdp.mg, :node_pos_mapping)[1] == (1, 2)
    @test get_prop(pomdp.mg, :node_pos_mapping)[2] == (2, 1)
    @test get_prop(pomdp.mg, :node_pos_mapping)[4] == (3, 1)
    @test get_prop(pomdp.mg, :node_mapping)[(3, 3)] == 6
    @test get_prop(pomdp.mg, :node_mapping)[(2, 3)] == 3

    map_str = "xxx\nxox\noox\nooo\nxxox"
    try # test invalid map
        TagPOMDP(; map_str=map_str)
        @test false
    catch
        @test true
    end
end
