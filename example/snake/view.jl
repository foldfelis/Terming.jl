using Crayons

const FORM_C = string(Crayon(foreground = :light_blue))
const HEAD_C = string(Crayon(foreground = :light_yellow))
const NODE_C = string(Crayon(foreground = :light_green))
const RES_C = string(Crayon(reset = true))

abstract type View end

struct FormView <: View
    size::Tuple{Int, Int}
    components::Vector{View}
end

function paint(form_view::FormView)
    stream = T.term.out_stream
    h, w = form_view.size

    print(stream, FORM_C)

    T.cmove(1, 1)
    print(stream, Char(0x250C)) # ┌
    print(stream, Char(0x2500)^(w-2))
    print(stream, Char(0x2510)) # ┐
    T.cmove_line_down()

    for i=2:(h-1)
        print(stream, Char(0x2502))
        print(stream, ' '^(w-2))
        print(stream, Char(0x2502))
        T.cmove_line_down()
    end

    print(stream, Char(0x2514)) # └
    print(stream, Char(0x2500)^(w-2))
    print(stream, Char(0x2518)) # ┘

    for component in form_view.components
        paint(component)
    end

    print(stream, RES_C)
end

struct SnakeView <: View
    snake::SnakeModel
end

function paint(snake_view::SnakeView)
    stream = T.term.out_stream

    print(stream, HEAD_C)
    for (i, node_pos) in enumerate(snake_view.snake.node_anchors)
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
