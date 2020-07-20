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
    h, w = form_view.size

    T.buffered() do buffer::IO
        T.print(FORM_C, stream=buffer)
        T.cmove(1, 1, stream=buffer)
        T.print(Char(0x250C), stream=buffer) # ┌
        T.print(Char(0x2500)^(w-2), stream=buffer)
        T.print(Char(0x2510), stream=buffer) # ┐
        T.cmove_line_down(stream=buffer)

        for i=2:(h-1)
            T.print(Char(0x2502), stream=buffer)
            T.print(' '^(w-2), stream=buffer)
            T.print(Char(0x2502), stream=buffer)
            T.cmove_line_down(stream=buffer)
        end

        T.print(Char(0x2514), stream=buffer) # └
        T.print(Char(0x2500)^(w-2), stream=buffer)
        T.print(Char(0x2518), stream=buffer) # ┘
        T.print(RES_C, stream=buffer)
    end

    for component in form_view.components
        paint(component)
    end
end

struct SnakeView <: View
    snake::SnakeModel
end

function paint(snake_view::SnakeView)
    T.buffered() do buffer::IO
        T.print(HEAD_C, stream=buffer)
        for (i, node_pos) in enumerate(snake_view.snake.node_anchors)
            y, x = node_pos
            T.cmove(y, x, stream=buffer)
            T.csave(stream=buffer)
            T.print("┌┐", stream=buffer)
            T.crestore(stream=buffer)
            T.cmove_down(stream=buffer)
            T.print("└┘", stream=buffer)

            (i == 1) && (T.print(NODE_C, stream=buffer))
        end
        T.print(RES_C, stream=buffer)
    end
end
