@testset "terminal.wrapping" begin

    @test T.displaysize() == (24, 80)

    T.cmove_up()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1A"
    T.cmove_up(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5A"
    T.cmove_down()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1B"
    T.cmove_down(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5B"
    T.cmove_left()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1D"
    T.cmove_left(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5D"
    T.cmove_right()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1C"
    T.cmove_right(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5C"
    T.cmove_line_up()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1A\r"
    T.cmove_line_up(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5A\r"
    T.cmove_line_down()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)1B\r"
    T.cmove_line_down(5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)5B\r"
    T.cmove_col(5)
    @test T.read_buffer(stream=T.term.out_stream) == "\r$(T.CSI)4C"

    T.clear()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)H$(T.CSI)2J"
    T.clear_line()
    @test T.read_buffer(stream=T.term.out_stream) == "\r$(T.CSI)0K"

    T.raw!(true)
    @test T.term.raw == true
    T.raw!(false)
    @test T.term.raw == false

    T.beep() # does this function ever work?? >_<
    @test T.read_next_char(T.term.err_stream) == '\x7'
    T.enable_bracketed_paste()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)?2004h"
    T.disable_bracketed_paste()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)?2004l"
    T.end_keypad_transmit_mode()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)?1l\e>"

end

@testset "terminal.extension" begin

    T.displaysize(30, 50)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)8;$(30);$(50)t"

    T.cmove(6, 5)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)6;5H"

    T.cmove_line_last()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)24;1H"

    T.cshow()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)?25h"

    T.cshow(false)
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)?25l"

    T.csave()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)s"

    T.crestore()
    @test T.read_buffer(stream=T.term.out_stream) == "$(T.CSI)u"

end

@testset "terminal.utils" begin

    T.raw!(true)

    fake_input("k")
    @test T.read_buffer() == "k"

    fake_input("\t")
    @test T.read_buffer() == "\t"

    fake_input("$(T.CSI)Z")
    @test T.read_buffer() == "\e[Z"

    T.raw!(false)

end
