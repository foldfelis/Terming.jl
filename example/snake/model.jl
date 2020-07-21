abstract type Model end

mutable struct SnakeModel <: Model
    status::Symbol
    size_properties::Tuple{Int, Int, Int, Int} # node_h, node_w, parent_h, parent_w
    direction::Symbol
    node_anchors::Vector{Tuple{Int, Int}}
    global_event_queue::Channel
end

function SnakeModel(parent_h::Int, parent_w::Int, event_queue::Channel; init_pos=(4, 50))
    # ┌┐
    # └┘
    node_h = node_w = 2
    anchors = [init_pos]
    for i=1:3
        push!(anchors, (init_pos[1], init_pos[2]-node_w*i))
    end

    return SnakeModel(:alive, (node_h, node_w, parent_h, parent_w), :right, anchors, event_queue)
end,

struct UpdateEvent <: T.Event end

struct LossEvent <: T.Event end

function bump(snake_model::SnakeModel)
    put!(snake_model.global_event_queue, LossEvent())
    snake_model.status = :dead
    return false
end

function move(snake_model::SnakeModel, direction::Symbol)
    (snake_model.status === :dead) && return false
    (snake_model.direction===:up && direction===:down) && return true
    (snake_model.direction===:down && direction===:up) && return true
    (snake_model.direction===:right && direction===:left) && return true
    (snake_model.direction===:left && direction===:right) && return true

    h, w, ph, pw = snake_model.size_properties
    if direction === :up
        new_anchor = snake_model.node_anchors[1].-(h, 0)
        (new_anchor[1] < 1) && return bump(snake_model)
    elseif direction === :down
        new_anchor = snake_model.node_anchors[1].+(h, 0)
        (new_anchor[1]+h > ph) && return bump(snake_model)
    elseif direction === :right
        new_anchor = snake_model.node_anchors[1].+(0, w)
        (new_anchor[2]+w > pw) && return bump(snake_model)
    elseif direction === :left
        new_anchor = snake_model.node_anchors[1].-(0, w)
        (new_anchor[2] < 1) && return bump(snake_model)
    end

    pop!(snake_model.node_anchors)
    pushfirst!(snake_model.node_anchors, new_anchor)
    snake_model.direction = direction

    put!(snake_model.global_event_queue, UpdateEvent())

    return true
end

function auto_move(snake_model::SnakeModel)
    Base.Threads.@spawn begin
        while move(snake_model, snake_model.direction)
            sleep(0.5)
        end
    end
end
