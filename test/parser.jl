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

            function create_ctls(ctls_code::Int)
                if ctls_code == 2
                    return T.SHIFT
                elseif ctls_code == 3
                    return T.CTRL
                elseif ctls_code == 4
                    return T.SHIFT_ALT
                elseif ctls_code == 5
                    return T.ALT
                elseif ctls_code == 6
                    return T.SHIFT_CTRL
                elseif ctls_code == 7
                    return T.CTRL_ALT
                elseif ctls_code == 8
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

                function test_vt(; ctls_code=-1, ctls=T.NO_CTL)
                    if ctls_code != -1
                        ctls_str = ";$(ctls_code)"
                    else
                        ctls_str = ""
                    end

                    @test T.parse_sequence("\e[1$(ctls_str)~") === T.KeyPressedEvent(T.HOME, ctls)
                    @test T.parse_sequence("\e[2$(ctls_str)~") === T.KeyPressedEvent(T.INSERT, ctls)
                    @test T.parse_sequence("\e[3$(ctls_str)~") === T.KeyPressedEvent(T.DELETE, ctls)
                    @test T.parse_sequence("\e[4$(ctls_str)~") === T.KeyPressedEvent(T.END, ctls)
                    @test T.parse_sequence("\e[5$(ctls_str)~") === T.KeyPressedEvent(T.PAGEUP, ctls)
                    @test T.parse_sequence("\e[6$(ctls_str)~") === T.KeyPressedEvent(T.PAGEDOWN, ctls)
                    @test T.parse_sequence("\e[7$(ctls_str)~") === T.KeyPressedEvent(T.HOME, ctls)
                    @test T.parse_sequence("\e[8$(ctls_str)~") === T.KeyPressedEvent(T.END, ctls)
                    @test T.parse_sequence("\e[9$(ctls_str)~") === T.PasteEvent("\e[9$(ctls_str)~")
                    @test T.parse_sequence("\e[10$(ctls_str)~") === T.PasteEvent("\e[10$(ctls_str)~") # F0
                    @test T.parse_sequence("\e[11$(ctls_str)~") === T.KeyPressedEvent(T.F1, ctls)
                    @test T.parse_sequence("\e[12$(ctls_str)~") === T.KeyPressedEvent(T.F2, ctls)
                    @test T.parse_sequence("\e[13$(ctls_str)~") === T.KeyPressedEvent(T.F3, ctls)
                    @test T.parse_sequence("\e[14$(ctls_str)~") === T.KeyPressedEvent(T.F4, ctls)
                    @test T.parse_sequence("\e[15$(ctls_str)~") === T.KeyPressedEvent(T.F5, ctls)
                    @test T.parse_sequence("\e[16$(ctls_str)~") === T.PasteEvent("\e[16$(ctls_str)~")
                    @test T.parse_sequence("\e[17$(ctls_str)~") === T.KeyPressedEvent(T.F6, ctls)
                    @test T.parse_sequence("\e[18$(ctls_str)~") === T.KeyPressedEvent(T.F7, ctls)
                    @test T.parse_sequence("\e[19$(ctls_str)~") === T.KeyPressedEvent(T.F8, ctls)
                    @test T.parse_sequence("\e[20$(ctls_str)~") === T.KeyPressedEvent(T.F9, ctls)
                    @test T.parse_sequence("\e[21$(ctls_str)~") === T.KeyPressedEvent(T.F10, ctls)
                    @test T.parse_sequence("\e[22$(ctls_str)~") === T.PasteEvent("\e[22$(ctls_str)~")
                    @test T.parse_sequence("\e[23$(ctls_str)~") === T.KeyPressedEvent(T.F11, ctls)
                    @test T.parse_sequence("\e[24$(ctls_str)~") === T.KeyPressedEvent(T.F12, ctls)
                    @test T.parse_sequence("\e[25$(ctls_str)~") === T.PasteEvent("\e[25$(ctls_str)~") # F13
                    @test T.parse_sequence("\e[26$(ctls_str)~") === T.PasteEvent("\e[26$(ctls_str)~") # F14
                    @test T.parse_sequence("\e[27$(ctls_str)~") === T.PasteEvent("\e[27$(ctls_str)~")
                    @test T.parse_sequence("\e[28$(ctls_str)~") === T.PasteEvent("\e[28$(ctls_str)~") # F15
                    @test T.parse_sequence("\e[29$(ctls_str)~") === T.PasteEvent("\e[29$(ctls_str)~") # F16
                    @test T.parse_sequence("\e[30$(ctls_str)~") === T.PasteEvent("\e[30$(ctls_str)~")
                    @test T.parse_sequence("\e[31$(ctls_str)~") === T.PasteEvent("\e[31$(ctls_str)~") # F17
                    @test T.parse_sequence("\e[32$(ctls_str)~") === T.PasteEvent("\e[32$(ctls_str)~") # F18
                    @test T.parse_sequence("\e[33$(ctls_str)~") === T.PasteEvent("\e[33$(ctls_str)~") # F19
                    @test T.parse_sequence("\e[34$(ctls_str)~") === T.PasteEvent("\e[34$(ctls_str)~") # F20
                    @test T.parse_sequence("\e[35$(ctls_str)~") === T.PasteEvent("\e[35$(ctls_str)~")
                end

                @testset "with AdjointKeys" begin

                    # +------------------------------------------------------------------+
                    # | the form of the sequence: "\e[<code>;<ctls_code>~" and code=1:35 |
                    # +------------------------------------------------------------------+
                    for i in 2:8
                        test_vt(ctls_code=i, ctls=create_ctls(i))
                    end

                end

                @testset "without AdjointKeys" begin

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

                function test_xterm(; ctls_code=-1, ctls=T.NO_CTL)
                    if ctls_code != -1
                        ctls_str = "1;$(ctls_code)"
                    else
                        ctls_str = ""
                    end

                    @test T.parse_sequence("\e[$(ctls_str)A") === T.KeyPressedEvent(T.UP, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)B") === T.KeyPressedEvent(T.DOWN, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)C") === T.KeyPressedEvent(T.RIGHT, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)D") === T.KeyPressedEvent(T.LEFT, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)E") === T.PasteEvent("\e[$(ctls_str)E")
                    @test T.parse_sequence("\e[$(ctls_str)F") === T.KeyPressedEvent(T.END, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)G") === T.KeyPressedEvent('5', ctls)
                    @test T.parse_sequence("\e[$(ctls_str)H") === T.KeyPressedEvent(T.HOME, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)I") === T.PasteEvent("\e[$(ctls_str)I")
                    @test T.parse_sequence("\e[$(ctls_str)J") === T.PasteEvent("\e[$(ctls_str)J")
                    @test T.parse_sequence("\e[$(ctls_str)K") === T.PasteEvent("\e[$(ctls_str)K")
                    @test T.parse_sequence("\e[$(ctls_str)L") === T.PasteEvent("\e[$(ctls_str)L")
                    @test T.parse_sequence("\e[$(ctls_str)M") === T.PasteEvent("\e[$(ctls_str)M")
                    @test T.parse_sequence("\e[$(ctls_str)N") === T.PasteEvent("\e[$(ctls_str)N")
                    @test T.parse_sequence("\e[$(ctls_str)O") === T.PasteEvent("\e[$(ctls_str)O")
                    if ctls_code != -1
                    @test T.parse_sequence("\e[$(ctls_str)P") === T.KeyPressedEvent(T.F1, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)Q") === T.KeyPressedEvent(T.F2, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)R") === T.KeyPressedEvent(T.F3, ctls)
                    @test T.parse_sequence("\e[$(ctls_str)S") === T.KeyPressedEvent(T.F4, ctls)
                    end
                    @test T.parse_sequence("\e[$(ctls_str)T") === T.PasteEvent("\e[$(ctls_str)T")
                    @test T.parse_sequence("\e[$(ctls_str)U") === T.PasteEvent("\e[$(ctls_str)U")
                    @test T.parse_sequence("\e[$(ctls_str)V") === T.PasteEvent("\e[$(ctls_str)V")
                    @test T.parse_sequence("\e[$(ctls_str)W") === T.PasteEvent("\e[$(ctls_str)W")
                    @test T.parse_sequence("\e[$(ctls_str)X") === T.PasteEvent("\e[$(ctls_str)X")
                    @test T.parse_sequence("\e[$(ctls_str)Y") === T.PasteEvent("\e[$(ctls_str)Y")
                    @test T.parse_sequence("\e[$(ctls_str)Z") === T.KeyPressedEvent(T.BACKTAB, ctls)
                end

                @testset "with AdjointKeys" begin

                    # +-----------------------------------------------------------------+
                    # | the form of the sequence: "\e[1;<ctls_code><code>" and code=A:Z |
                    # +-----------------------------------------------------------------+
                    for i in 2:8
                        test_xterm(ctls_code=i, ctls=create_ctls(i))
                    end

                end

                @testset "without AdjointKeys" begin

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
