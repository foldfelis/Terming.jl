@testset "terminal.wrapping" begin

    @test T.displaysize() == (24, 80)

    T.cmove_up()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1A"
    T.cmove_up(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5A"
    T.cmove_down()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1B"
    T.cmove_down(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5B"
    T.cmove_left()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1D"
    T.cmove_left(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5D"
    T.cmove_right()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1C"
    T.cmove_right(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5C"
    T.cmove_line_up()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1A\r"
    T.cmove_line_up(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5A\r"
    T.cmove_line_down()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)1B\r"
    T.cmove_line_down(5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)5B\r"
    T.cmove_col(5)
    @test T.read_strem(stream=T.out_stream) == "\r$(T.CSI)4C"

    T.clear()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)H$(T.CSI)2J"
    T.clear_line()
    @test T.read_strem(stream=T.out_stream) == "\r$(T.CSI)0K"

    T.raw!(true)
    @test T.term.raw == true
    T.raw!(false)
    @test T.term.raw == false

    T.beep()
    @test T.read_next_char(T.err_stream) == '\x7'
    T.enable_bracketed_paste()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)?2004h"
    T.disable_bracketed_paste()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)?2004l"
    T.end_keypad_transmit_mode()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)?1l\e>"

end

@testset "terminal.extension" begin

    T.displaysize(30, 50)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)8;$(30);$(50)t"

    T.cmove(6, 5)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)6;5H"

    T.cmove_line_last()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)24;1H"

    T.cshow()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)?25h"

    T.cshow(false)
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)?25l"

    T.csave()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)s"

    T.crestore()
    @test T.read_strem(stream=T.out_stream) == "$(T.CSI)u"

end

@testset "io" begin

    T.write("a")
    @test T.read_strem(stream=T.out_stream) == "a"

    T.write("a", "a")
    @test T.read_strem(stream=T.out_stream) == "aa"

    T.print("a")
    @test T.read_strem(stream=T.out_stream) == "a"

    T.print("a", "a")
    @test T.read_strem(stream=T.out_stream) == "aa"

    T.println("a")
    @test T.read_strem(stream=T.out_stream) == "a\n"

    T.println("a", "a")
    @test T.read_strem(stream=T.out_stream) == "aa\n"

    list = ["a", "b", "c", "d"]
    T.join(list, ", ", " and ")
    @test T.read_strem(stream=T.out_stream) == "a, b, c and d"

end

@testset "terminal.utils" begin

    T.raw!(true)

    fake_input("k")
    @test T.read_strem() == "k"

    fake_input("\t")
    @test T.read_strem() == "\t"

    fake_input("$(T.CSI)Z")
    @test T.read_strem() == "\e[Z"

    T.raw!(false)

end

@testset "buffered" begin

    @testset "terminal.wrapping" begin

    T.cmove_up(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1A"
    T.cmove_up(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5A"
    T.cmove_down(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1B"
    T.cmove_down(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5B"
    T.cmove_left(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1D"
    T.cmove_left(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5D"
    T.cmove_right(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1C"
    T.cmove_right(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5C"
    T.cmove_line_up(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1A\r"
    T.cmove_line_up(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5A\r"
    T.cmove_line_down(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)1B\r"
    T.cmove_line_down(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)5B\r"
    T.cmove_col(5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "\r$(T.CSI)4C"

    T.clear(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)H$(T.CSI)2J"
    T.clear_line(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "\r$(T.CSI)0K"

    T.enable_bracketed_paste(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)?2004h"
    T.disable_bracketed_paste(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)?2004l"
    T.end_keypad_transmit_mode(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)?1l\e>"

    end

    @testset "terminal.extension" begin

    T.displaysize(30, 50, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)8;$(30);$(50)t"

    T.cmove(6, 5, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)6;5H"

    T.cmove_line_last(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)24;1H"

    T.cshow(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)?25h"

    T.cshow(false, buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)?25l"

    T.csave(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)s"

    T.crestore(buffered=true)
    @test T.read_strem(stream=T.buffered_out_stream) == "$(T.CSI)u"

    end

    @testset "utils" begin

        str = "This stream will be sand into buffered then into stdout"
        Base.write(T.buffered_out_stream, str)

        T.flush()
        @test T.read_strem(stream=T.out_stream) == str

    end

end
