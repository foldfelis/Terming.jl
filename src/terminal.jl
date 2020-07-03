using REPL

export # wrapping
    CSI,
    displaysize,
    cmove_up,
    cmove_down,
    cmove_left,
    cmove_right,
    cmove_line_up,
    cmove_line_down,
    cmove_col,
    clear,
    clear_line,
    raw!,
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
    read_buffer

# +---------------------------+
# | wrpping of REPL.Terminals |
# +---------------------------+

const CSI = REPL.Terminals.CSI

displaysize(; t=term) = REPL.Terminals.displaysize(t)

cmove_up(n::Int; t=term) = REPL.Terminals.cmove_up(t, n)
cmove_up(; t=term) = REPL.Terminals.cmove_up(t)
cmove_down(n::Int; t=term) = REPL.Terminals.cmove_down(t, n)
cmove_down(; t=term) = REPL.Terminals.cmove_down(t)
cmove_left(n::Int; t=term) = REPL.Terminals.cmove_left(t, n)
cmove_left(; t=term) = REPL.Terminals.cmove_left(t)
cmove_right(n::Int; t=term) = REPL.Terminals.cmove_right(t, n)
cmove_right(; t=term) = REPL.Terminals.cmove_right(t)
cmove_line_up(n::Int; t=term) = REPL.Terminals.cmove_line_up(t, n) # CSI n F
cmove_line_up(; t=term) = REPL.Terminals.cmove_line_up(t)
cmove_line_down(n::Int; t=term) = REPL.Terminals.cmove_line_down(t, n) # SCI n E
cmove_line_down(; t=term) = REPL.Terminals.cmove_line_down(t)
cmove_col(n::Int; t=term) = REPL.Terminals.cmove_col(t, n) # SCI n G

clear(; t=term) = REPL.Terminals.clear(t)
clear_line(t=term) =  REPL.Terminals.clear_line(t)

raw!(enable::Bool; t=term) = REPL.Terminals.raw!(t, enable)

beep(; t=term) = REPL.Terminals.beep(t)
enable_bracketed_paste(; t=term) = REPL.Terminals.enable_bracketed_paste(t)
disable_bracketed_paste(; t=term) = REPL.Terminals.disable_bracketed_paste(t)
end_keypad_transmit_mode(; t=term) = REPL.Terminals.end_keypad_transmit_mode(t)

# +------------+
# | extensions |
# +------------+

cmove(y::Int, x::Int; t=term) = write(t.out_stream, "$(CSI)$(y);$(x)H")
cmove_line_last(; t=term) = write(t.out_stream, "$(CSI)$(displaysize()[1]);1H")

clear_line(row::Int; t=term) = (write(t.out_stream, "$(CSI)$(row);1H"); clear_line())

cshow(enable=true; t=term) = enable ? write(t.out_stream, "$(CSI)?25h") : write(t.out_stream, "$(CSI)?25l")

csave(; t=term) = write(t.out_stream, "$(CSI)s")
crestore(; t=term) = write(t.out_stream, "$(CSI)u")

# +-------+
# | utils |
# +-------+

function init_term(; in_stream=stdin, out_stream=stdout, err_stream=stderr)
    return REPL.Terminals.TTYTerminal(
        get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"),
        in_stream, out_stream, err_stream
    )
end

read_next_char(io::IO) = Char(read(io, 1)[1])

function read_buffer(; t=term)
    c = string(read_next_char(t.in_stream))

    stream_size = t.in_stream.buffer.size
    if stream_size > 1
        for i=1:stream_size-1
            c *= read_next_char(t.in_stream)
        end
    end

    return c
end
