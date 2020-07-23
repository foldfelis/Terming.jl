@testset "terminal.wrapping" begin

    @test T.displaysize() == (24, 80)

    T.cmove_up()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1A"
    T.cmove_up(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5A"
    T.cmove_down()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1B"
    T.cmove_down(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5B"
    T.cmove_left()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1D"
    T.cmove_left(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5D"
    T.cmove_right()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1C"
    T.cmove_right(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5C"
    T.cmove_line_up()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1A\r"
    T.cmove_line_up(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5A\r"
    T.cmove_line_down()
    @test T.read_stream(T.out_stream) == "$(T.CSI)1B\r"
    T.cmove_line_down(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5B\r"
    T.cmove_col()
    @test T.read_stream(T.out_stream) == "\r"
    T.cmove_col(5)
    @test T.read_stream(T.out_stream) == "\r$(T.CSI)4C"

    T.clear()
    @test T.read_stream(T.out_stream) == "$(T.CSI)H$(T.CSI)2J"
    T.clear_line()
    @test T.read_stream(T.out_stream) == "\r$(T.CSI)0K"

    T.raw!(true)
    @test T.term.raw == true
    T.raw!(false)
    @test T.term.raw == false

    T.beep()
    @test T.read_next_char(T.err_stream) == '\x7'
    T.enable_bracketed_paste()
    @test T.read_stream(T.out_stream) == "$(T.CSI)?2004h"
    T.disable_bracketed_paste()
    @test T.read_stream(T.out_stream) == "$(T.CSI)?2004l"
    T.end_keypad_transmit_mode()
    @test T.read_stream(T.out_stream) == "$(T.CSI)?1l\e>"

end

@testset "terminal.wrapping redirect stream" begin

    fake_out_stream = Base.BufferStream()

    T.cmove_up(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1A"
    T.cmove_up(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5A"
    T.cmove_down(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1B"
    T.cmove_down(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5B"
    T.cmove_left(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1D"
    T.cmove_left(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5D"
    T.cmove_right(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1C"
    T.cmove_right(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5C"
    T.cmove_line_up(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1A\r"
    T.cmove_line_up(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5A\r"
    T.cmove_line_down(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)1B\r"
    T.cmove_line_down(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "$(T.CSI)5B\r"
    T.cmove_col(fake_out_stream)
    @test T.read_stream(fake_out_stream) == "\r"
    T.cmove_col(fake_out_stream, 5)
    @test T.read_stream(fake_out_stream) == "\r$(T.CSI)4C"

end

@testset "terminal.extension" begin

    T.displaysize(30, 50)
    @test T.read_stream(T.out_stream) == "$(T.CSI)8;$(30);$(50)t"

    T.cmove(6, 5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)6;5H"

    T.cmove_line_last()
    @test T.read_stream(T.out_stream) == "$(T.CSI)24;1H"

    T.clear_line(5)
    @test T.read_stream(T.out_stream) == "$(T.CSI)5;1H\r$(T.CSI)0K"

    T.cshow()
    @test T.read_stream(T.out_stream) == "$(T.CSI)?25h"

    T.cshow(false)
    @test T.read_stream(T.out_stream) == "$(T.CSI)?25l"

    T.csave()
    @test T.read_stream(T.out_stream) == "$(T.CSI)s"

    T.crestore()
    @test T.read_stream(T.out_stream) == "$(T.CSI)u"

    T.alt_screen(true)
    @test T.read_stream(T.out_stream) == "$(T.CSI)?1049h"

    T.alt_screen(false)
    @test T.read_stream(T.out_stream) == "$(T.CSI)?1049l"

end

@testset "io" begin

    T.write("a")
    @test T.read_stream(T.out_stream) == "a"

    T.write("a", "a")
    @test T.read_stream(T.out_stream) == "aa"

    T.print("a")
    @test T.read_stream(T.out_stream) == "a"

    T.print("a", "a")
    @test T.read_stream(T.out_stream) == "aa"

    T.println("a")
    @test T.read_stream(T.out_stream) == "a\n"

    T.println("a", "a")
    @test T.read_stream(T.out_stream) == "aa\n"

    list = ["a", "b", "c", "d"]
    T.join(list, ", ", " and ")
    @test T.read_stream(T.out_stream) == "a, b, c and d"

end

@testset "io redirect stream" begin

    fake_out_stream = Base.BufferStream()

    T.write(fake_out_stream, "a")
    @test T.read_stream(fake_out_stream) == "a"

    T.write(fake_out_stream, "a", "a")
    @test T.read_stream(fake_out_stream) == "aa"

    T.print(fake_out_stream, "a")
    @test T.read_stream(fake_out_stream) == "a"

    T.print(fake_out_stream, "a", "a")
    @test T.read_stream(fake_out_stream) == "aa"

    T.println(fake_out_stream, "a")
    @test T.read_stream(fake_out_stream) == "a\n"

    T.println(fake_out_stream, "a", "a")
    @test T.read_stream(fake_out_stream) == "aa\n"

    list = ["a", "b", "c", "d"]
    T.join(fake_out_stream, list, ", ", " and ")
    @test T.read_stream(fake_out_stream) == "a, b, c and d"

end

@testset "terminal.utils" begin

    T.raw!(true)

    pseudo_input("k")
    @test T.read_stream() == "k"

    pseudo_input("\t")
    @test T.read_stream() == "\t"

    pseudo_input("$(T.CSI)Z")
    @test T.read_stream() == "\e[Z"

    T.raw!(false)

end

@testset "buffered" begin

    # redirect out_stream to a larger buffer
    fake_out_stream = Base.BufferStream()

    function paint(buffer::IO)
        T.print(buffer, "buffered string")
    end

    T.buffered(paint, fake_out_stream)
    @test T.read_stream(fake_out_stream) == "buffered string"

    # no redirection
    T.buffered(paint)
    @test T.read_stream(T.out_stream) == "buffered string"

    # do expr
    T.buffered() do buffer
        T.println(buffer, "buffered string 1")
        T.println(buffer, "buffered string 2")
        T.println(buffer, "buffered string 3")
    end
    @test T.read_stream(T.out_stream) ==
        "buffered string 1\n" *
        "buffered string 2\n" *
        "buffered string 3\n"

    # with extra argv
    struct CustomType end

    render(stream::IO, ::CustomType) = T.print(stream, "CustomType()")
    T.buffered(render, CustomType())
    @test T.read_stream(T.out_stream) == "CustomType()"

    T.buffered(CustomType()) do buffer::IO, ::CustomType
        T.print(buffer, "CustomType()")
    end
    @test T.read_stream(T.out_stream) == "CustomType()"

    T.buffered(fake_out_stream, CustomType()) do buffer::IO, ::CustomType
        T.print(buffer, "CustomType()")
    end
    @test T.read_stream(fake_out_stream) == "CustomType()"

end
