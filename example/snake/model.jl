struct UpdateEvent <: T.Event end

function move(snake::Snake, direction::Symbol)
    (snake.direction===:up && direction===:down) && return true
    (snake.direction===:down && direction===:up) && return true
    (snake.direction===:right && direction===:left) && return true
    (snake.direction===:left && direction===:right) && return true

    if direction === :up
        new_anchor = snake.node_anchors[1].-(S_H, 0)
        (new_anchor[1] < 1) && return false
    elseif direction === :down
        new_anchor = snake.node_anchors[1].+(S_H, 0)
        (new_anchor[1]+S_H > H) && return false
    elseif direction === :right
        new_anchor = snake.node_anchors[1].+(0, S_W)
        (new_anchor[2]+S_W > W) && return false
    elseif direction === :left
        new_anchor = snake.node_anchors[1].-(0, S_W)
        (new_anchor[2] < 1) && return false
    end

    pop!(snake.node_anchors)
    pushfirst!(snake.node_anchors, new_anchor)
    snake.direction = direction

    put!(EVENT_QUEUE, UpdateEvent())

    return true
end

function auto_move(snake::Snake)
    Base.Threads.@spawn begin
        while move(snake, snake.direction)
            put!(EVENT_QUEUE, UpdateEvent())
            sleep(0.5)
        end
    end
end
