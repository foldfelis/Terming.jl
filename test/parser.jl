@testset "parser" begin

    # parse_single_char_sequence
    # Enter
    @show T.parse_sequence("\n")
    @show T.parse_sequence("\r")
    # Esc
    @show T.parse_sequence("\e")
    # Teb
    @show T.parse_sequence("\t")
    # Backspace
    @show T.parse_sequence("\x7F")
    # Null
    @show T.parse_sequence("\0")
    # Ctrl
    for i=0x01:0x1A
        @show T.parse_sequence(string(Char(i)))
    end
    for i=0x1C:0x1F
        @show T.parse_sequence(string(Char(i)))
    end
    # Char
    @show T.parse_sequence("p")
    @show T.parse_sequence("😁")

    # parse_esc_leaded_sequence
    # F1 - F4
    @show T.parse_sequence("\e0P")
    @show T.parse_sequence("\e0Q")
    @show T.parse_sequence("\e0R")
    @show T.parse_sequence("\e0S")
    # Alt + Char
    @show T.parse_sequence("\eA")
end
