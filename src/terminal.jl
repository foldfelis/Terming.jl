using REPL

export # wrapping
    CSI,
    displaysize,
    raw!,
    cmove_up,
    cmove_down,
    cmove_left,
    cmove_right,
    cmove_line_up,
    cmove_line_down,
    cmove_col,
    clear,
    clear_line,
    beep,
    enable_bracketed_paste,
    disable_bracketed_paste,
    end_keypad_transmit_mode

export # extensions
    displaysize,
    cmove,
    clear_line,
    cmove_line_last,
    cshow,
    csave,
    crestore

export # io
    write,
    print,
    println,
    join

export # utils
    read_next_char,
    init_term,
    read_strem_bytes,
    read_strem,
    flush,
    buffered

export FakeTerminal, fake_input

# +---------------------------+
# | wrpping of REPL.Terminals |
# +---------------------------+

const CSI = REPL.Terminals.CSI

displaysize(; t=term) = REPL.Terminals.displaysize(t)
raw!(enable::Bool; t=term) = REPL.Terminals.raw!(t, enable)

cmove_up(n::Int; stream=out_stream) = Base.write(stream, "$(CSI)$(n)A")
cmove_up(; stream=out_stream) = cmove_up(1, stream=stream)
cmove_down(n::Int; stream=out_stream) = Base.write(stream, "$(CSI)$(n)B")
cmove_down(; stream=out_stream) = cmove_down(1, stream=stream)
cmove_right(n::Int; stream=out_stream) = Base.write(stream, "$(CSI)$(n)C")
cmove_right(; stream=out_stream) = cmove_right(1, stream=stream)
cmove_left(n::Int; stream=out_stream) = Base.write(stream, "$(CSI)$(n)D")
cmove_left(; stream=out_stream) = cmove_left(1, stream=stream)
cmove_col(n::Int; stream=out_stream) = (Base.write(stream, '\r'); n > 1 && cmove_right(n-1, stream=stream)) # SCI n G
cmove_col(; stream=out_stream) = cmove_col(1, stream=stream)
cmove_line_up(n::Int; stream=out_stream) = (cmove_up(n, stream=stream); cmove_col(stream=stream)) # CSI n F
cmove_line_up(; stream=out_stream) = cmove_line_up(1, stream=stream)
cmove_line_down(n::Int; stream=out_stream) = (cmove_down(n, stream=stream); cmove_col(stream=stream)) # SCI n E
cmove_line_down(; stream=out_stream) = cmove_line_down(1, stream=stream)

@eval clear(; stream=out_stream) = Base.write(stream, $"$(CSI)H$(CSI)2J")
@eval clear_line(; stream=out_stream) = Base.write(stream, $"\r$(CSI)0K")

beep(; stream=err_stream) = Base.write(stream,"\x7")

@eval enable_bracketed_paste(; stream=out_stream) = Base.write(stream, $"$(CSI)?2004h")
@eval disable_bracketed_paste(; stream=out_stream) = Base.write(stream, $"$(CSI)?2004l")
@eval end_keypad_transmit_mode(; stream=out_stream) = Base.write(stream, $"$(CSI)?1l\x1b>")

# +------------+
# | extensions |
# +------------+

displaysize(height::Int, width::Int; stream=out_stream) = Base.write(stream, "$(CSI)8;$(height);$(width)t")

cmove(y::Int, x::Int; stream=out_stream) = Base.write(stream, "$(CSI)$(y);$(x)H")
cmove_line_last(; stream=out_stream) = Base.write(stream, "$(CSI)$(displaysize()[1]);1H")

clear_line(row::Int; stream=out_stream) = (Base.write(stream, "$(CSI)$(row);1H"); clear_line())

cshow(enable=true; stream=out_stream) = (enable ? Base.write(stream, "$(CSI)?25h") : Base.write(stream, "$(CSI)?25l"))

csave(; stream=out_stream) = Base.write(stream, "$(CSI)s")
crestore(; stream=out_stream) = Base.write(stream, "$(CSI)u")

# +----+
# | IO |
# +----+

write(args...; stream=out_stream) = Base.write(stream, args...)
print(args...; stream=out_stream) = Base.print(stream, args...)
println(args...; stream=out_stream) = Base.println(stream, args...)
join(args...; stream=out_stream) = Base.join(stream, args...)

# +-------+
# | utils |
# +-------+

function init_term(; in_stream=stdin, out_stream=stdout, err_stream=stderr)
    return REPL.Terminals.TTYTerminal(
        get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"),
        in_stream, out_stream, err_stream
    )
end

read_next_byte(io::IO) = read(io, 1)[1]

function read_strem_bytes(; stream=in_stream)
    queue = UInt8[]

    push!(queue, read_next_byte(stream))

    stream_size = stream.buffer.size
    if stream_size > 1
        for i=1:stream_size-1
            push!(queue, read_next_byte(stream))
        end
    end

    return queue
end

read_next_char(io::IO) = Char(read_next_byte(io))

read_strem(; stream=in_stream) = String(read_strem_bytes(stream=stream))

flush(stream::IO, buffer::Base.BufferStream) = Base.write(stream, read_strem(stream=buffer))

function buffered(f; stream=out_stream)
    buffer=Base.BufferStream()
    f(buffer)
    flush(stream, buffer)

    return
end

# +---------------+
# | fake terminal |
# +---------------+

mutable struct FakeTerminal <: REPL.Terminals.UnixTerminal
    term_type::String
    in_stream::Base.IO
    out_stream::Base.IO
    err_stream::Base.IO
    raw::Bool
end

FakeTerminal(in::Base.IO, out::Base.IO, err::Base.IO) = FakeTerminal(
    get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"),
    in, out, err,
    false
)

REPL.Terminals.raw!(t::FakeTerminal, raw::Bool) = (t.raw = raw)

REPL.Terminals.displaysize(::FakeTerminal) = (24, 80)

fake_input(key::String; t=term) = Base.print(t.in_stream, key)
