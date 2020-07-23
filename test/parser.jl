@testset "parser" begin

    @testset "paste event" begin

        str = "This is a good parser"
        @test T.parse_sequence(str) === T.PasteEvent(str)

    end

    @testset "parse_single_char_sequence" begin

        # @info "Enter"
        enter_event = T.KeyPressedEvent(T.ENTER)
        @test T.parse_sequence("\n") === enter_event
        @test T.parse_sequence("\r") === enter_event

        # @info "Esc"
        @test T.parse_sequence("\e") === T.KeyPressedEvent(T.ESC)

        # @info "Teb"
        @test T.parse_sequence("\t") === T.KeyPressedEvent(T.TAB)

        # @info "Backspace"
        @test T.parse_sequence("\x7F") === T.KeyPressedEvent(T.BACKSPACE)

        # @info "Null"
        @test T.parse_sequence("\0") === T.KeyPressedEvent(T.NULL)

        # @info "Ctrl 'a' - 'z', '1' - '4'"
        for i=0x01:0x1A
            if i == 'i'-'a'+0x01
                # char = '\t'
                e = T.KeyPressedEvent(T.TAB)
            elseif i == 'j'-'a'+0x01
                # char = '\n'
                e = T.KeyPressedEvent(T.ENTER)
            elseif i == 'm'-'a'+0x01
                # char = '\r'
                e = T.KeyPressedEvent(T.ENTER)
            else
                e = T.KeyPressedEvent(Char(i-0x01+'a'), T.CTRL)
            end

            @test T.parse_sequence(string(Char(i))) === e
        end
        for i=0x1C:0x1F
            char = Char(i-0x1C+'4')
            @test T.parse_sequence(string(Char(i))) === T.KeyPressedEvent(char, T.CTRL)
        end

        # @info "Char"
        @test T.parse_sequence("p") === T.KeyPressedEvent('p')
        @test T.parse_sequence("😁") === T.KeyPressedEvent('😁') # TODO: This doesn't seem right

    end

    @testset "parse_esc_leaded_sequence" begin

        @testset "F1 - F4" begin

            @test T.parse_sequence("\eOP") === T.KeyPressedEvent(T.F1)
            @test T.parse_sequence("\eOQ") === T.KeyPressedEvent(T.F2)
            @test T.parse_sequence("\eOR") === T.KeyPressedEvent(T.F3)
            @test T.parse_sequence("\eOS") === T.KeyPressedEvent(T.F4)

            @testset "F1 - F4 fallback" begin

                str = "\eOz"
                @test T.parse_sequence(str) === T.PasteEvent(str)

            end

        end

        @testset "parse_csi" begin

            @testset "parse_csi fallback" begin

                str = "\e["
                @test T.parse_sequence(str) === T.PasteEvent(str)

            end

            function create_adjoint(adjoint_code::Int)
                if adjoint_code == 2
                    return T.SHIFT
                elseif adjoint_code == 3
                    return T.CTRL
                elseif adjoint_code == 4
                    return T.SHIFT_ALT
                elseif adjoint_code == 5
                    return T.ALT
                elseif adjoint_code == 6
                    return T.SHIFT_CTRL
                elseif adjoint_code == 7
                    return T.CTRL_ALT
                elseif adjoint_code == 8
                    return T.SHIFT_CTRL_ALT
                else
                    return -1
                end
            end

            @testset "vt sequence" begin

                @testset "vt sequence fallback" begin

                    str = "\e[;~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[a;~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[;b~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[a;b~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[1;9~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)

                    str = "\e[~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[a~"
                    @test T.parse_sequence(str) === T.PasteEvent(str)

                end

                function test_vt(; adjoint_code=-1, adjoint=T.NO_ADJOINT)
                    if adjoint_code != -1
                        adjoint_str = ";$(adjoint_code)"
                    else
                        adjoint_str = ""
                    end

                    @test T.parse_sequence("\e[1$(adjoint_str)~") === T.KeyPressedEvent(T.HOME, adjoint)
                    @test T.parse_sequence("\e[2$(adjoint_str)~") === T.KeyPressedEvent(T.INSERT, adjoint)
                    @test T.parse_sequence("\e[3$(adjoint_str)~") === T.KeyPressedEvent(T.DELETE, adjoint)
                    @test T.parse_sequence("\e[4$(adjoint_str)~") === T.KeyPressedEvent(T.END, adjoint)
                    @test T.parse_sequence("\e[5$(adjoint_str)~") === T.KeyPressedEvent(T.PAGEUP, adjoint)
                    @test T.parse_sequence("\e[6$(adjoint_str)~") === T.KeyPressedEvent(T.PAGEDOWN, adjoint)
                    @test T.parse_sequence("\e[7$(adjoint_str)~") === T.KeyPressedEvent(T.HOME, adjoint)
                    @test T.parse_sequence("\e[8$(adjoint_str)~") === T.KeyPressedEvent(T.END, adjoint)
                    @test T.parse_sequence("\e[9$(adjoint_str)~") === T.PasteEvent("\e[9$(adjoint_str)~")
                    @test T.parse_sequence("\e[10$(adjoint_str)~") === T.PasteEvent("\e[10$(adjoint_str)~") # F0
                    @test T.parse_sequence("\e[11$(adjoint_str)~") === T.KeyPressedEvent(T.F1, adjoint)
                    @test T.parse_sequence("\e[12$(adjoint_str)~") === T.KeyPressedEvent(T.F2, adjoint)
                    @test T.parse_sequence("\e[13$(adjoint_str)~") === T.KeyPressedEvent(T.F3, adjoint)
                    @test T.parse_sequence("\e[14$(adjoint_str)~") === T.KeyPressedEvent(T.F4, adjoint)
                    @test T.parse_sequence("\e[15$(adjoint_str)~") === T.KeyPressedEvent(T.F5, adjoint)
                    @test T.parse_sequence("\e[16$(adjoint_str)~") === T.PasteEvent("\e[16$(adjoint_str)~")
                    @test T.parse_sequence("\e[17$(adjoint_str)~") === T.KeyPressedEvent(T.F6, adjoint)
                    @test T.parse_sequence("\e[18$(adjoint_str)~") === T.KeyPressedEvent(T.F7, adjoint)
                    @test T.parse_sequence("\e[19$(adjoint_str)~") === T.KeyPressedEvent(T.F8, adjoint)
                    @test T.parse_sequence("\e[20$(adjoint_str)~") === T.KeyPressedEvent(T.F9, adjoint)
                    @test T.parse_sequence("\e[21$(adjoint_str)~") === T.KeyPressedEvent(T.F10, adjoint)
                    @test T.parse_sequence("\e[22$(adjoint_str)~") === T.PasteEvent("\e[22$(adjoint_str)~")
                    @test T.parse_sequence("\e[23$(adjoint_str)~") === T.KeyPressedEvent(T.F11, adjoint)
                    @test T.parse_sequence("\e[24$(adjoint_str)~") === T.KeyPressedEvent(T.F12, adjoint)
                    @test T.parse_sequence("\e[25$(adjoint_str)~") === T.PasteEvent("\e[25$(adjoint_str)~") # F13
                    @test T.parse_sequence("\e[26$(adjoint_str)~") === T.PasteEvent("\e[26$(adjoint_str)~") # F14
                    @test T.parse_sequence("\e[27$(adjoint_str)~") === T.PasteEvent("\e[27$(adjoint_str)~")
                    @test T.parse_sequence("\e[28$(adjoint_str)~") === T.PasteEvent("\e[28$(adjoint_str)~") # F15
                    @test T.parse_sequence("\e[29$(adjoint_str)~") === T.PasteEvent("\e[29$(adjoint_str)~") # F16
                    @test T.parse_sequence("\e[30$(adjoint_str)~") === T.PasteEvent("\e[30$(adjoint_str)~")
                    @test T.parse_sequence("\e[31$(adjoint_str)~") === T.PasteEvent("\e[31$(adjoint_str)~") # F17
                    @test T.parse_sequence("\e[32$(adjoint_str)~") === T.PasteEvent("\e[32$(adjoint_str)~") # F18
                    @test T.parse_sequence("\e[33$(adjoint_str)~") === T.PasteEvent("\e[33$(adjoint_str)~") # F19
                    @test T.parse_sequence("\e[34$(adjoint_str)~") === T.PasteEvent("\e[34$(adjoint_str)~") # F20
                    @test T.parse_sequence("\e[35$(adjoint_str)~") === T.PasteEvent("\e[35$(adjoint_str)~")
                end

                @testset "with AdjointKey" begin

                    # +------------------------------------------------------------------+
                    # | the form of the sequence: "\e[<code>;<adjoint_code>~" and code=1:35 |
                    # +------------------------------------------------------------------+
                    for i in 2:8
                        test_vt(adjoint_code=i, adjoint=create_adjoint(i))
                    end

                end

                @testset "without AdjointKey" begin

                    # +------------------------------------------------------+
                    # | the form of the sequence: "\e[<code>~" and code=1:35 |
                    # +------------------------------------------------------+
                    test_vt()

                end

            end

            @testset "xterm sequence" begin

                @testset "vt sequence fallback" begin

                    str = "\e[;"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[a;8A"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[1;8AA"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[1;aa"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[1;9A"
                    @test T.parse_sequence(str) === T.PasteEvent(str)

                    str = "\e["
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[99"
                    @test T.parse_sequence(str) === T.PasteEvent(str)
                    str = "\e[a"
                    @test T.parse_sequence(str) === T.PasteEvent(str)

                end

                function test_xterm(; adjoint_code=-1, adjoint=T.NO_ADJOINT)
                    if adjoint_code != -1
                        adjoint_str = "1;$(adjoint_code)"
                    else
                        adjoint_str = ""
                    end

                    @test T.parse_sequence("\e[$(adjoint_str)A") === T.KeyPressedEvent(T.UP, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)B") === T.KeyPressedEvent(T.DOWN, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)C") === T.KeyPressedEvent(T.RIGHT, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)D") === T.KeyPressedEvent(T.LEFT, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)E") === T.PasteEvent("\e[$(adjoint_str)E")
                    @test T.parse_sequence("\e[$(adjoint_str)F") === T.KeyPressedEvent(T.END, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)G") === T.KeyPressedEvent('5', adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)H") === T.KeyPressedEvent(T.HOME, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)I") === T.PasteEvent("\e[$(adjoint_str)I")
                    @test T.parse_sequence("\e[$(adjoint_str)J") === T.PasteEvent("\e[$(adjoint_str)J")
                    @test T.parse_sequence("\e[$(adjoint_str)K") === T.PasteEvent("\e[$(adjoint_str)K")
                    @test T.parse_sequence("\e[$(adjoint_str)L") === T.PasteEvent("\e[$(adjoint_str)L")
                    @test T.parse_sequence("\e[$(adjoint_str)M") === T.PasteEvent("\e[$(adjoint_str)M")
                    @test T.parse_sequence("\e[$(adjoint_str)N") === T.PasteEvent("\e[$(adjoint_str)N")
                    @test T.parse_sequence("\e[$(adjoint_str)O") === T.PasteEvent("\e[$(adjoint_str)O")
                    if adjoint_code != -1
                    @test T.parse_sequence("\e[$(adjoint_str)P") === T.KeyPressedEvent(T.F1, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)Q") === T.KeyPressedEvent(T.F2, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)R") === T.KeyPressedEvent(T.F3, adjoint)
                    @test T.parse_sequence("\e[$(adjoint_str)S") === T.KeyPressedEvent(T.F4, adjoint)
                    end
                    @test T.parse_sequence("\e[$(adjoint_str)T") === T.PasteEvent("\e[$(adjoint_str)T")
                    @test T.parse_sequence("\e[$(adjoint_str)U") === T.PasteEvent("\e[$(adjoint_str)U")
                    @test T.parse_sequence("\e[$(adjoint_str)V") === T.PasteEvent("\e[$(adjoint_str)V")
                    @test T.parse_sequence("\e[$(adjoint_str)W") === T.PasteEvent("\e[$(adjoint_str)W")
                    @test T.parse_sequence("\e[$(adjoint_str)X") === T.PasteEvent("\e[$(adjoint_str)X")
                    @test T.parse_sequence("\e[$(adjoint_str)Y") === T.PasteEvent("\e[$(adjoint_str)Y")
                    @test T.parse_sequence("\e[$(adjoint_str)Z") === T.KeyPressedEvent(T.BACKTAB, adjoint)
                end

                @testset "with AdjointKey" begin

                    # +-----------------------------------------------------------------+
                    # | the form of the sequence: "\e[1;<adjoint_code><code>" and code=A:Z |
                    # +-----------------------------------------------------------------+
                    for i in 2:8
                        test_xterm(adjoint_code=i, adjoint=create_adjoint(i))
                    end

                end

                @testset "without AdjointKey" begin

                    # +----------------------------------------------------+
                    # | the form of the sequence: "\e[<code>" and code=A:Z |
                    # +----------------------------------------------------+
                    test_xterm()

                end

            end

        end

        @testset "ALT + Char" begin

            @test T.parse_sequence("\eA") === T.KeyPressedEvent('A', T.ALT)

        end

        @testset "parse_esc_leaded_sequence fallback" begin

            str = "\efallback"
            @test T.parse_sequence(str) === T.PasteEvent(str)

        end

    end

end
