function read_out_buffer(; t=T.term)
    c = string(T.read_next_char(t.out_stream))

    stream_size = t.out_stream.buffer.size
    if stream_size > 1
        for i=1:stream_size-1
            c *= T.read_next_char(t.out_stream)
        end
    end

    return c
end

@testset "terminal.wrapping" begin

    @test T.displaysize() == (24, 80)

    T.cmove_up()
    @test read_out_buffer() == "$(T.CSI)1A"
    T.cmove_up(5)
    @test read_out_buffer() == "$(T.CSI)5A"
    T.cmove_down()
    @test read_out_buffer() == "$(T.CSI)1B"
    T.cmove_down(5)
    @test read_out_buffer() == "$(T.CSI)5B"
    T.cmove_left()
    @test read_out_buffer() == "$(T.CSI)1D"
    T.cmove_left(5)
    @test read_out_buffer() == "$(T.CSI)5D"
    T.cmove_right()
    @test read_out_buffer() == "$(T.CSI)1C"
    T.cmove_right(5)
    @test read_out_buffer() == "$(T.CSI)5C"
    T.cmove_line_up()
    @test read_out_buffer() == "$(T.CSI)1A\r"
    T.cmove_line_up(5)
    @test read_out_buffer() == "$(T.CSI)5A\r"
    T.cmove_line_down()
    @test read_out_buffer() == "$(T.CSI)1B\r"
    T.cmove_line_down(5)
    @test read_out_buffer() == "$(T.CSI)5B\r"
    T.cmove_col(5)
    @test read_out_buffer() == "\r$(T.CSI)4C"

    T.clear()
    @test read_out_buffer() == "$(T.CSI)H$(T.CSI)2J"
    T.clear_line()
    @test read_out_buffer() == "\r$(T.CSI)0K"

    T.raw!(true)
    @test T.term.raw == true
    T.raw!(false)
    @test T.term.raw == false

    T.beep() # does this function ever work?? >_<
    @test T.read_next_char(T.term.err_stream) == '\x7'
    T.enable_bracketed_paste()
    @test read_out_buffer() == "$(T.CSI)?2004h"
    T.disable_bracketed_paste()
    @test read_out_buffer() == "$(T.CSI)?2004l"
    T.end_keypad_transmit_mode()
    @test read_out_buffer() == "$(T.CSI)?1l\e>"

end

@testset "terminal.extension" begin

    T.displaysize(30, 50)
    @test read_out_buffer() == "$(T.CSI)8;$(30);$(50)t"

    T.cmove(6, 5)
    @test read_out_buffer() == "$(T.CSI)6;5H"

    T.cmove_line_last()
    @test read_out_buffer() == "$(T.CSI)24;1H"

    T.cshow()
    @test read_out_buffer() == "$(T.CSI)?25h"

    T.cshow(false)
    @test read_out_buffer() == "$(T.CSI)?25l"

    T.csave()
    @test read_out_buffer() == "$(T.CSI)s"

    T.crestore()
    @test read_out_buffer() == "$(T.CSI)u"

end

@testset "terminal.utils" begin

    T.raw!(true)

    fake_key_press("k")
    @test T.read_buffer() == "k"

    fake_key_press("\t")
    @test T.read_buffer() == "\t"

    fake_key_press("$(T.CSI)Z")
    @test T.read_buffer() == "\e[Z"

    T.raw!(false)

end

# @testset "terminal.manual" begin

#     T.set_term!(T.init_term())

#     c = ""
#     while c != "\033"
#         T.raw!(true)
#         c = T.read_buffer()
#         T.raw!(false)

#         @show c
#     end

# end
