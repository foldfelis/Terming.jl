@testset "terminal.wrapping" begin

    # displaysize returns (24, 80) owing to BufferStream has no `LINES` and `COLUMNS`
    # https://github.com/JuliaLang/julia/blob/be72a571a63e134788c8bb7d997098e9b9aee019/base/stream.jl#L488
    @test T.displaysize() == (24, 80)

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

    T.cmove_up()
    @test string(read_out_buffer()) == "$(T.CSI)1A"
    T.cmove_up(5)
    @test string(read_out_buffer()) == "$(T.CSI)5A"

end

@testset "terminal.utils" begin

    fake_key_press("k")
    T.raw!(true)
    @test T.read_buffer() == "k"
    T.raw!(false)

end
