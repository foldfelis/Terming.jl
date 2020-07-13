using Crayons

const FORM_C = string(Crayon(foreground = :light_blue))
const HEAD_C = string(Crayon(foreground = :light_yellow))
const NODE_C = string(Crayon(foreground = :light_green))
const RES_C = string(Crayon(reset = true))

abstract type Component end

struct Form
    components::Vector{Component}
end

function paint(form::Form)
    stream = T.term.out_stream

    print(stream, FORM_C)

    T.cmove(1, 1)
    print(stream, Char(0x250C)) # ┌
    print(stream, Char(0x2500)^(W-2))
    print(stream, Char(0x2510)) # ┐

    for i=2:(H-1)
        print(stream, Char(0x2502))
        print(stream, ' '^(W-2))
        print(stream, Char(0x2502))
    end

    print(stream, Char(0x2514)) # └
    print(stream, Char(0x2500)^(W-2))
    print(stream, Char(0x2518)) # ┘

    for component in form.components
        paint(component)
    end

    print(stream, RES_C)
end

# node be like:
# ┌┐
# └┘
const S_H, S_W = SNAKE_NODE_SIZE = (2, 2)

mutable struct Snake <: Component
    direction::Symbol
    node_anchors::Vector{Tuple{Int, Int}}
end

function Snake(init_pos=(4, 50))
    anchors = [init_pos]
    for i=1:3
        push!(anchors, (init_pos[1], init_pos[2]-S_W*i))
    end

    return Snake(:right, anchors)
end

function paint(snake::Snake)
    stream = T.term.out_stream

    print(stream, HEAD_C)
    for (i, node_pos) in enumerate(snake.node_anchors)
        y, x = node_pos
        T.cmove(y, x)
        T.csave()
        print(stream, "┌┐")
        T.crestore()
        T.cmove_down()
        print(stream, "└┘")

        (i == 1) && (print(stream, NODE_C))
    end
end

struct View
    form::Form
end
