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

    T.@buffered begin
        T.print(FORM_C)
        T.cmove(1, 1)
        T.print(Char(0x250C)) # ┌
        T.print(Char(0x2500)^(w-2))
        T.print(Char(0x2510)) # ┐
        T.cmove_line_down()

        for i=2:(h-1)
            T.print(Char(0x2502))
            T.print(' '^(w-2))
            T.print(Char(0x2502))
            T.cmove_line_down()
        end

        T.print(Char(0x2514)) # └
        T.print(Char(0x2500)^(w-2))
        T.print(Char(0x2518)) # ┘
        T.print(RES_C)
    end

    for component in form_view.components
        paint(component)
    end
end

struct SnakeView <: View
    snake::SnakeModel
end

function paint(snake_view::SnakeView)
    T.@buffered begin
        T.print(HEAD_C)
        for (i, node_pos) in enumerate(snake_view.snake.node_anchors)
            y, x = node_pos
            T.cmove(y, x)
            T.csave()
            T.print("┌┐")
            T.crestore()
            T.cmove_down()
            T.print("└┘")

            (i == 1) && (T.print(NODE_C))
        end
        T.print(RES_C)
    end
end
