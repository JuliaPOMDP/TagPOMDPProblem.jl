
"""
    render(pomdp::TagPOMDP, step; pre_act_text::String="")

Render a TagPOMDP step as a plot. If the step contains a belief, the belief will be plotted
using a color gradient of green for the belief of the target position and belief over the
robot position will be plotted as an orange robot with a faded robot representing smaller
belief. If the step contains a state, the robot and target will be plotted in their
respective positions. If the step contains an action, the action will be plotted in the
bottom center of the plot. `pre_act_text` can be used to add text before the action text.

- `pomdp::TagPOMDP`: The TagPOMDP to render
- `step`: Step step to render as a Named Tuple with fields `b`, `s`, and `a`
- `pre_act_text::String`: Text to add before the action text
"""
function POMDPTools.render(pomdp::TagPOMDP, step; pre_act_text::String="")
    plt = nothing
    plotted_robot = false

    if !isnothing(get(step, :b, nothing))
        plt = plot_tag(pomdp, step.b)
        plotted_robot = true
    else
        plt = plot_tag(pomdp)
    end

    if !isnothing(get(step, :s, nothing))
        offset = (0.0, 0.0)
        if step.s.t_pos == step.s.r_pos
            offset = (0.0, 0.1)
        end
        t_x, t_y = get_prop(pomdp.mg, :node_pos_mapping)[step.s.t_pos]
        r_x, r_y = get_prop(pomdp.mg, :node_pos_mapping)[step.s.r_pos]
        plt = plot_robot!(plt, (t_y, -t_x) .+ offset; color=RGB(0.8, 0.1, 0.1))
        if !plotted_robot
            plt = plot_robot!(plt, (r_y, -r_x))
        end
    end

    if !isnothing(get(step, :a, nothing))
        # Determine appropriate font size based on plot size
        px_p_tick = px_per_tick(plt)
        fnt_size = Int(floor(px_p_tick / 2 / 1.3333333))
        num_cols = get_prop(pomdp.mg, :ncols)
        num_rows = get_prop(pomdp.mg, :nrows)
        xc = (num_cols + 1) / 2
        yc = -(num_rows + 1.0)
        action_text = pre_act_text * "a = $(ACTION_NAMES[step.a])"
        plt = annotate!(plt, xc, yc, (text(action_text, :black, :center, fnt_size)))
    end

    return plt

end

function plot_tag(pomdp::TagPOMDP)
    state_list = [sᵢ for sᵢ in pomdp]
    b = zeros(length(pomdp) - 1)
    return plot_tag(pomdp, b, state_list[1:end-1])
end
function plot_tag(pomdp::TagPOMDP, b::Vector{Float64})
    state_list = [sᵢ for sᵢ in pomdp]
    if length(b) == length(state_list)
        return plot_tag(pomdp, b[1:end-1], state_list[1:end-1])
    end
    error("Belief must be the same length as the state list unless passing a state_list")
end
function plot_tag(pomdp::TagPOMDP, b::DiscreteBelief)
    return plot_tag(pomdp, b.b[1:end-1], b.state_list[1:end-1])
end
function plot_tag(pomdp::TagPOMDP, b::SparseCat)
    return plot_tag(pomdp, b.probs, b.vals)
end

function plot_tag(pomdp::TagPOMDP, b::Vector, state_list::Vector{TagState};
    color_grad=cgrad(:Greens_9),
    prob_color_scale=1.0
)
    @assert length(b) == length(state_list) "Belief and state list must be the same length"
    num_cells = get_prop(pomdp.mg, :num_grid_pos)
    node_pos_mapping = get_prop(pomdp.mg, :node_pos_mapping)

    map_str = map_str_from_metagraph(pomdp)
    map_str_mat = Matrix{Char}(undef, get_prop(pomdp.mg, :nrows), get_prop(pomdp.mg, :ncols))
    for (i, line) in enumerate(split(map_str, '\n'))
        map_str_mat[i, :] .= collect(line)
    end

    # Get the belief of the robot and the target in each cell
    grid_t_b = zeros(num_cells)
    grid_r_b = zeros(num_cells)
    for (ii, sᵢ) in enumerate(state_list)
        grid_t_b[sᵢ.t_pos] += b[ii]
        grid_r_b[sᵢ.r_pos] += b[ii]
    end

    plt = plot(; legend=false, ticks=false, showaxis=false, grid=false, aspectratio=:equal)

    # Plot blank section at bottom for action text
    nc = get_prop(pomdp.mg, :ncols)
    nr = get_prop(pomdp.mg, :nrows)
    plt = plot!(plt, rect(0.0, 0.5, (nc+1)/2, -(nr+1.0)); linecolor=RGB(1.0, 1.0, 1.0), color=:white)

    node_mapping = get_prop(pomdp.mg, :node_mapping)
    # Plot the grid
    for xi in 1:get_prop(pomdp.mg, :nrows)
        for yj in 1:get_prop(pomdp.mg, :ncols)

            if map_str_mat[xi, yj] == 'x'
                color = :black
            else
                cell_i = node_mapping[(xi, yj)]
                color_scale = grid_t_b[cell_i] * prob_color_scale
                if color_scale < 0.05
                    color = :white
                else
                    color = get(color_grad, color_scale)
                end
            end

            plt = plot!(plt, rect(0.5, 0.5, yj, -xi); color=color)
        end
    end
    # Determine scale of font based on plot size
    px_p_tick = px_per_tick(plt)
    fnt_size = Int(floor(px_p_tick / 4 / 1.3333333))

    # Plot the robot (tranparancy based on belief) and annotate the target belief as well
    for cell_i in 1:num_cells
        xi, yi = node_pos_mapping[cell_i]
        prob_text = round(grid_t_b[cell_i]; digits=2)
        if prob_text < 0.01
            prob_text = ""
        end
        plt = annotate!(yi, -xi, (text(prob_text, :black, :center, fnt_size)))
        if grid_r_b[cell_i] >= 1/num_cells - 1e-5
            plt = plot_robot!(plt, (yi, -xi); fillalpha=grid_r_b[cell_i])
        end
    end
    return plt
end

function plot_robot!(plt::Plots.Plot, (x, y); fillalpha=1.0, color=RGB(1.0, 0.627, 0.0))
    body_size = 0.3
    la = 0.1
    lb = body_size
    leg_offset = 0.3
    plot!(plt, ellip(x + leg_offset, y, la, lb); color=color, fillalpha=fillalpha)
    plot!(plt, ellip(x - leg_offset, y, la, lb); color=color, fillalpha=fillalpha)
    plot!(plt, circ(x, y, body_size); color=color, fillalpha=fillalpha)
    return plt
end

function rect(w, h, x, y)
    return Shape(x .+ [w, -w, -w, w, w], y .+ [h, h, -h, -h, h])
end

function circ(x, y, r; kwargs...)
    return ellip(x, y, r, r; kwargs...)
end

function ellip(x, y, a, b; num_pts=25)
    angles = [range(0; stop=2π, length=num_pts); 0]
    xs = a .* sin.(angles) .+ x
    ys = b .* cos.(angles) .+ y
    return Shape(xs, ys)
end

function px_per_tick(plt)
    (x_size, y_size) = plt[:size]
    xlim = xlims(plt)
    ylim = ylims(plt)
    xlim_s = xlim[2] - xlim[1]
    ylim_s = ylim[2] - ylim[1]
    if xlim_s >= ylim_s
        px_p_tick = x_size / xlim_s
    else
        px_p_tick = y_size / ylim_s
    end
    return px_p_tick
end
