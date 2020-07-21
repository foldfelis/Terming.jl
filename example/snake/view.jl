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

    T.buffered() do buffer
        T.print(buffer, FORM_C)
        T.cmove(buffer, 1, 1)
        T.print(buffer, Char(0x250C)) # ┌
        T.print(buffer, Char(0x2500)^(w-2))
        T.print(buffer, Char(0x2510)) # ┐
        T.cmove_line_down(buffer)

        for i=2:(h-1)
            T.print(buffer, Char(0x2502))
            T.print(buffer, ' '^(w-2))
            T.print(buffer, Char(0x2502))
            T.cmove_line_down(buffer)
        end

        T.print(buffer, Char(0x2514)) # └
        T.print(buffer, Char(0x2500)^(w-2))
        T.print(buffer, Char(0x2518)) # ┘
        T.print(buffer, RES_C)
    end

    for component in form_view.components
        paint(component)
    end
end

struct SnakeView <: View
    snake::SnakeModel
end

function paint(snake_view::SnakeView)
    T.buffered() do buffer
        T.print(HEAD_C)
        for (i, node_pos) in enumerate(snake_view.snake.node_anchors)
            y, x = node_pos
            T.cmove(buffer, y, x)
            T.csave(buffer)
            T.print(buffer, "┌┐")
            T.crestore(buffer)
            T.cmove_down(buffer)
            T.print(buffer, "└┘")

            (i == 1) && (T.print(buffer, NODE_C))
        end
        T.print(buffer, RES_C)
    end
end
