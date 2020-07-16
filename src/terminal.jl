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
    cmove,
    clear_line

export # utils
    read_next_char,
    init_term,
    read_strem_bytes,
    read_strem,
    flush

# +---------------------------+
# | wrpping of REPL.Terminals |
# +---------------------------+

const CSI = REPL.Terminals.CSI

displaysize(; t=term) = REPL.Terminals.displaysize(t)
raw!(enable::Bool; t=term) = REPL.Terminals.raw!(t, enable)

function cmove_up(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(n)A")
end
function cmove_up(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_up(1, stream=stream)
end
function cmove_down(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(n)B")
end
function cmove_down(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_down(1, stream=stream)
end
function cmove_right(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(n)C")
end
function cmove_right(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_right(1, stream=stream)
end
function cmove_left(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(n)D")
end
function cmove_left(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_left(1, stream=stream)
end
function cmove_col(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    (write(stream, '\r'); n > 1 && cmove_right(n-1, stream=stream)) # SCI n G
end
function cmove_col(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_col(1, stream=stream)
end
function cmove_line_up(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    (cmove_up(n, stream=stream); cmove_col(stream=stream)) # CSI n F
end
function cmove_line_up(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_line_up(1, stream=stream)
end
function cmove_line_down(n::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    (cmove_down(n, stream=stream); cmove_col(stream=stream)) # SCI n E
end
function cmove_line_down(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    cmove_line_down(1, stream=stream)
end

@eval function clear(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, $"$(CSI)H$(CSI)2J")
end
@eval function clear_line(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, $"\r$(CSI)0K")
end

beep(; stream=err_stream) = write(stream,"\x7")

@eval function enable_bracketed_paste(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, $"$(CSI)?2004h")
end
@eval function disable_bracketed_paste(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, $"$(CSI)?2004l")
end
@eval function end_keypad_transmit_mode(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, $"$(CSI)?1l\x1b>")
end

# +------------+
# | extensions |
# +------------+

function displaysize(height::Int, width::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)8;$(height);$(width)t")
end

function cmove(y::Int, x::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(y);$(x)H")
end
function cmove_line_last(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)$(displaysize()[1]);1H")
end

function clear_line(row::Int; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    (write(stream, "$(CSI)$(row);1H"); clear_line())
end

function cshow(enable=true; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    enable ? write(stream, "$(CSI)?25h") : write(stream, "$(CSI)?25l")
end

function csave(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)s")
end
function crestore(; stream=out_stream, buffered=false)
    stream = buffered ? buffered_out_stream : stream
    write(stream, "$(CSI)u")
end

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

flush(; stream=out_stream, buffer=buffered_out_stream) = write(stream, read_strem(stream=buffered_out_stream))
