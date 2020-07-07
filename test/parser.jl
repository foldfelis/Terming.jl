@testset "parser" begin

    @info "parse_single_char_sequence"

    @info "Enter"
    @show T.parse_sequence("\n")
    @show T.parse_sequence("\r")
    @info "Esc"
    @show T.parse_sequence("\e")
    @info "Teb"
    @show T.parse_sequence("\t")
    @info "Backspace"
    @show T.parse_sequence("\x7F")
    @info "Null"
    @show T.parse_sequence("\0")
    @info "Ctrl"
    for i=0x01:0x1A
        @show T.parse_sequence(string(Char(i)))
    end
    for i=0x1C:0x1F
        @show T.parse_sequence(string(Char(i)))
    end
    @info "Char"
    @show T.parse_sequence("p")
    @show T.parse_sequence("😁")

    @info "parse_esc_leaded_sequence"

    @info "F1 - F4"
    @show T.parse_sequence("\eOP")
    @show T.parse_sequence("\eOQ")
    @show T.parse_sequence("\eOR")
    @show T.parse_sequence("\eOS")
    @info "Alt + Char"
    @show T.parse_sequence("\eA")

    @info "parse_csi"

    @info "direction keys"
    @show T.parse_sequence("\e[A")
    @show T.parse_sequence("\e[B")
    @show T.parse_sequence("\e[C")
    @show T.parse_sequence("\e[D")
    @show T.parse_sequence("\e[H")
    @show T.parse_sequence("\e[F")
    @show T.parse_sequence("\e[Z")
    @info "F5 - F12 and spetial keys with ctl key"
    for j=2:8
        for i=1:8
            @show T.parse_sequence("\e[$(i);$(j)~")
        end
        for i=11:15
            @show T.parse_sequence("\e[$(i);$(j)~")
        end
        for i=17:21
            @show T.parse_sequence("\e[$(i);$(j)~")
        end
        for i=23:24
            @show T.parse_sequence("\e[$(i);$(j)~")
        end
    end
    @info "F5 - F12 and spetial keys"
    for i=1:8
        @show T.parse_sequence("\e[$(i)~")
    end
    for i=11:15
        @show T.parse_sequence("\e[$(i)~")
    end
    for i=17:21
        @show T.parse_sequence("\e[$(i)~")
    end
    for i=23:24
        @show T.parse_sequence("\e[$(i)~")
    end
    @info "F1 - F4 with ctl key"
    for i=2:8
        for key in ['P', 'Q', 'R', 'S', 'A', 'B', 'C', 'D', 'H', 'F', 'Z']
            @show T.parse_sequence("\e[1;$(i)$(key)")
        end
    end

end
