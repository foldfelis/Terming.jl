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
    @show T.parse_sequence("\eOP")
    @show T.parse_sequence("\eOQ")
    @show T.parse_sequence("\eOR")
    @show T.parse_sequence("\eOS")
    # Alt + Char
    @show T.parse_sequence("\eA")

    # parse_csi
    # direction keys
    @show T.parse_sequence("\e[A")
    @show T.parse_sequence("\e[B")
    @show T.parse_sequence("\e[C")
    @show T.parse_sequence("\e[D")
    @show T.parse_sequence("\e[H")
    @show T.parse_sequence("\e[F")
    @show T.parse_sequence("\e[Z")
    # F5 - F12
    @show T.parse_sequence("\e[15~")
    @show T.parse_sequence("\e[17~")
    @show T.parse_sequence("\e[18~")
    @show T.parse_sequence("\e[19~")
    @show T.parse_sequence("\e[20~")
    @show T.parse_sequence("\e[21~")
    @show T.parse_sequence("\e[23~")
    @show T.parse_sequence("\e[24~")

end
