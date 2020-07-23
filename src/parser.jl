export parse_sequence

function parse_sequence(sequence::String)
    if length(sequence) == 1
        return parse_single_char_sequence(Char(sequence[1]))
    end

    (c, state) = iterate(sequence)
    if c == '\e'
        return parse_esc_leaded_sequence(sequence, state)
    end

    return PasteEvent(sequence) # fallback
end

function parse_single_char_sequence(sequence::Char, is_alt=false)
    if is_alt
        adjoint_key = ALT
        adjoint_ctrl = CTRL_ALT
    else
        adjoint_key = NO_ADJOINT
        adjoint_ctrl = CTRL
    end

    if sequence == '\n' || sequence == '\r' # ENTER
        return KeyPressedEvent(ENTER, adjoint_key)
    elseif sequence == '\e' # ESC
        return KeyPressedEvent(ESC, adjoint_key)
    elseif sequence == '\t' # TAB
        return KeyPressedEvent(TAB, adjoint_key)
    elseif sequence == '\x7F' #BACKSPACE
        return KeyPressedEvent(BACKSPACE, adjoint_key)
    elseif sequence == '\0' # NULL
        return KeyPressedEvent(NULL, adjoint_key)
    elseif any(isequal(sequence), Char(0x01):Char(0x1A)) # CTRL + key
        return KeyPressedEvent(Char(UInt8(sequence)-0x01+UInt8('a')), adjoint_ctrl)
    elseif any(isequal(sequence), Char(0x0C):Char(0x1F)) # CTRL + key
        return KeyPressedEvent(Char(UInt8(sequence)-0x1C+UInt8('4')), adjoint_ctrl)
    else # single char
        return KeyPressedEvent(sequence, adjoint_key)
    end
end

function parse_esc_leaded_sequence(sequence::String, state::Int)
    (c, state) = iterate(sequence, state)
    if c == 'O' # F1 - F4
        return parse_xterm_f1_2_f4(sequence, state)
    elseif c == '[' # Some CSI sequence
        return parse_csi(sequence, state)
    elseif iterate(sequence, state) === nothing # ALT + key
        return parse_single_char_sequence(c, true)
    end

    return PasteEvent(sequence) # fallback
end

function parse_xterm_f1_2_f4(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return PasteEvent(sequence)) # fallback

    (c, state) = next
    if any(isequal(c), 'P':'S')
        return KeyPressedEvent(SpecialKey(UInt8(c)-UInt8('P')))
    end

    return PasteEvent(sequence) # fallback
end

function parse_csi(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return PasteEvent(sequence)) # fallback

    if sequence[end] == '~' # vt sequence
        code_sequence = sequence[state:(end-1)]
        if ';' in code_sequence # with adjoint keys
            # +------------------------------------------------------------------+
            # | the form of the sequence: "\e[<code>;<adjoint_code>~" and code=1:35 |
            # +------------------------------------------------------------------+
            code, adjoint_code = tryparse.(Int, split(code_sequence, ';'))
            (code === nothing || adjoint_code === nothing) && (return PasteEvent(sequence))  # fallback
            adjoint = parse_adjoint_key_code(adjoint_code)
            (adjoint == -1) && (return PasteEvent(sequence))  # fallback
        else # without adjoint keys
            # +------------------------------------------------------+
            # | the form of the sequence: "\e[<code>~" and code=1:35 |
            # +------------------------------------------------------+
            code = tryparse(Int, code_sequence)
            (code === nothing) && (return PasteEvent(sequence))  # fallback
            adjoint = NO_ADJOINT
        end

        return parse_vt_code(sequence, code, adjoint)
    else # xterm sequence
        code_sequence = sequence[state:end]
        if ';' in code_sequence # with adjoint keys
            # +-----------------------------------------------------------------+
            # | the form of the sequence: "\e[1;<adjoint_code><code>" and code=A:Z |
            # +-----------------------------------------------------------------+
            id, code_sequence = split(code_sequence, ';')
            (id != "1" || length(code_sequence) != 2) && (return PasteEvent(sequence))  # fallback

            # determing key code
            c = code_sequence[2]
            if any(isequal(c), 'P':'S') # F1 - F4 with adjoint keys have the same form
                code = Int(c)-Int('P') # code=1:3, matches the enum F1 - F4
            else
                code = Int(c)
            end

            # construct AdjointKey array
            adjoint_code = tryparse(Int, string(code_sequence[1]))
            (adjoint_code === nothing) && (return PasteEvent(sequence)) # fallback
            adjoint = parse_adjoint_key_code(adjoint_code)
            (adjoint == -1) && (return PasteEvent(sequence))  # fallback
        else # without adjoint keys (not including F1 - F4)
            # +----------------------------------------------------+
            # | the form of the sequence: "\e[<code>" and code=A:Z |
            # +----------------------------------------------------+
            (length(code_sequence) != 1) && (return PasteEvent(sequence))  # fallback

            # determing key code
            code = Int(code_sequence[1])

            # construct AdjointKey
            adjoint = NO_ADJOINT
        end

        return parse_xterm_code(sequence, code, adjoint)
    end
end

function parse_vt_code(sequence::String, code::Int, adjoint=NO_ADJOINT)
    if code in 1:6 # HOME INSERT DELETE END PAGEUP PAGEDOWN
        enum_bias = 11
        return KeyPressedEvent(SpecialKey(code+enum_bias), adjoint)
    elseif code == 7 # HOME
        return KeyPressedEvent(HOME, adjoint)
    elseif code == 8 # END
        return KeyPressedEvent(END, adjoint)
    elseif code in 11:15 # F1 - F5
        return KeyPressedEvent(SpecialKey(code-11), adjoint)
    elseif code in 17:21 # F6 - f10
        return KeyPressedEvent(SpecialKey(code-12), adjoint)
    elseif code in 23:24 # F11 - F12
        return KeyPressedEvent(SpecialKey(code-13), adjoint)
    end

    return PasteEvent(sequence) # fallback
end

function parse_xterm_code(sequence::String, code::Int, adjoint=NO_ADJOINT)
    if code in Int('A'):Int('D') || code == Int('Z') # UP DOWN RIGHT LEFT BACKTAB
        return KeyPressedEvent(SpecialKey(code), adjoint)
    elseif code == Int('F') # END
        return KeyPressedEvent(END, adjoint)
    elseif code == Int('G') # Keypad 5
        return KeyPressedEvent('5', adjoint)
    elseif code == Int('H') # HOME
        return KeyPressedEvent(HOME, adjoint)
    elseif code in 0:3 # F1 - F4 with adjoint keys have the same form
        return KeyPressedEvent(SpecialKey(code), adjoint)
    end

    return PasteEvent(sequence) # fallback
end

function parse_adjoint_key_code(code::Int)
    if  code in 2:8
        return AdjointKey(code)
    end

    return -1 # fallback
end
