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

cmove_up(stream::IO, n::Int) = Base.write(stream, "$(CSI)$(n)A")
cmove_up(n::Int) = cmove_up(out_stream, n)
cmove_up(stream::IO) = cmove_up(stream, 1)
cmove_up()  = cmove_up(1)

cmove_down(stream::IO, n::Int) = Base.write(stream, "$(CSI)$(n)B")
cmove_down(n::Int) = cmove_down(out_stream, n)
cmove_down(stream::IO) = cmove_down(stream, 1)
cmove_down() = cmove_down(1)

cmove_right(stream::IO, n::Int) = Base.write(stream, "$(CSI)$(n)C")
cmove_right(n::Int) = cmove_right(out_stream, n)
cmove_right(stream::IO) = cmove_right(stream, 1)
cmove_right() = cmove_right(1)

cmove_left(stream::IO, n::Int) = Base.write(stream, "$(CSI)$(n)D")
cmove_left(n::Int) = cmove_left(out_stream, n)
cmove_left(stream::IO) = cmove_left(stream, 1)
cmove_left() = cmove_left(1)

cmove_col(stream::IO, n::Int) = (Base.write(stream, '\r'); n > 1 && cmove_right(stream, n-1)) # SCI n G
cmove_col(n::Int) = cmove_col(out_stream, n)
cmove_col(stream::IO) = cmove_col(stream, 1)
cmove_col() = cmove_col(1)

cmove_line_up(stream::IO, n::Int) = (cmove_up(stream, n); cmove_col(stream)) # CSI n F
cmove_line_up(n::Int) = cmove_line_up(out_stream, n)
cmove_line_up(stream::IO) = cmove_line_up(stream, 1)
cmove_line_up() = cmove_line_up(1)

cmove_line_down(stream::IO, n::Int) = (cmove_down(stream, n); cmove_col(stream)) # SCI n E
cmove_line_down(n::Int) = cmove_line_down(out_stream, n)
cmove_line_down(stream::IO) = cmove_line_down(stream, 1)
cmove_line_down() = cmove_line_down(1)


@eval clear(stream::IO) = Base.write(stream, $"$(CSI)H$(CSI)2J")
clear() = clear(out_stream)

@eval clear_line(stream::IO) = Base.write(stream, $"\r$(CSI)0K")
clear_line() = clear_line(out_stream)

beep(stream::IO) = Base.write(stream,"\x7")
beep() = beep(err_stream)

@eval enable_bracketed_paste(stream::IO) = Base.write(stream, $"$(CSI)?2004h")
enable_bracketed_paste() = enable_bracketed_paste(out_stream)

@eval disable_bracketed_paste(stream::IO) = Base.write(stream, $"$(CSI)?2004l")
disable_bracketed_paste() = disable_bracketed_paste(out_stream)

@eval end_keypad_transmit_mode(stream::IO) = Base.write(stream, $"$(CSI)?1l\x1b>")
end_keypad_transmit_mode() = end_keypad_transmit_mode(out_stream)


# +------------+
# | extensions |
# +------------+

displaysize(stream::IO, height::Int, width::Int) = Base.write(stream, "$(CSI)8;$(height);$(width)t")
displaysize(height::Int, width::Int) = displaysize(out_stream, height, width)

cmove(stream::IO, y::Int, x::Int) = Base.write(stream, "$(CSI)$(y);$(x)H")
cmove(y::Int, x::Int) = cmove(out_stream, y, x)

cmove_line_last(stream::IO) = Base.write(stream, "$(CSI)$(displaysize()[1]);1H")
cmove_line_last() = cmove_line_last(out_stream)

clear_line(stream::IO, row::Int) = (Base.write(stream, "$(CSI)$(row);1H"); clear_line())
clear_line(row::Int) = clear_line(out_stream, row)

cshow(stream::IO, enable=true) = (enable ? Base.write(stream, "$(CSI)?25h") : Base.write(stream, "$(CSI)?25l"))
cshow(enable=true) = cshow(out_stream, enable)

csave(stream::IO) = Base.write(stream, "$(CSI)s")
csave() = csave(out_stream)

crestore(stream::IO) = Base.write(stream, "$(CSI)u")
crestore() = crestore(out_stream)

# +----+
# | IO |
# +----+

write(stream::IO, args...) = Base.write(stream, args...)
write(args...) = Base.write(out_stream, args...)

print(stream::IO, args...) = Base.print(stream, args...)
print(args...) = Base.print(out_stream, args...)

println(stream::IO, args...) = Base.println(stream, args...)
println(args...) = Base.println(out_stream, args...)

join(stream::IO, args...) = Base.join(stream, args...)
join(args...) = Base.join(out_stream, args...)


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

function read_strem_bytes(stream::IO)
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

read_strem(stream::IO) = String(read_strem_bytes(stream))
read_strem() = read_strem(in_stream)

flush(stream::IO, buffer::Base.BufferStream) = Base.write(stream, read_strem(buffer))

function buffered(stream::IO, f, argv...)
    buffer=Base.BufferStream()
    f(buffer, argv...)
    flush(stream, buffer)

    return
end

buffered(f, argv...) = buffered(out_stream, f, argv...)

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
