using Terming
using Crayons

function main()
    Terming.cshow(false)
    Terming.displaysize(20, 75); Terming.clear()

    julia_str = [
    "     _       _ _       ",
    "    | |_   _| (_) __ _ ",
    " _  | | | | | | |/ _` |",
    "| |_| | |_| | | | (_| |",
    " \\___/ \\__,_|_|_|\\__,_|"
    ]

    Terming.buffered() do buffer
        Terming.cmove(2, 2)
        for str in julia_str
            Terming.csave(buffer)
            Terming.print(buffer, Crayon(foreground=(175, 122, 197), bold=false), str)
            Terming.crestore(buffer)
            Terming.cmove_down(buffer)
        end
        Terming.print(buffer, "-"^73)

        Terming.cmove_line_down(buffer, 2); Terming.cmove_col(buffer, 2)
        Terming.print(buffer, Crayon(foreground=(93, 173, 226), bold=true), "[noun]")

        Terming.cmove_line_down(buffer, 1); Terming.cmove_col(buffer, 6)
        def_str = "The Julia Language: A fresh approach to technical computing."
        Terming.print(buffer, Crayon(foreground=(88, 214, 141), bold=false), def_str)

        Terming.cmove_line_down(buffer, 2); Terming.cmove_col(buffer, 2)
        Terming.print(buffer, Crayon(foreground=(93, 173, 226), bold=true), "[verb]")

        Terming.cmove_line_down(buffer, 1); Terming.cmove_col(buffer, 6)
        def_str = "To write code in Julia."
        Terming.print(buffer, Crayon(foreground=(88, 214, 141), bold=false), def_str)

        Terming.cmove_line_last(buffer)
    end

    readline()

    Terming.cshow(true)

    return
end

main()
