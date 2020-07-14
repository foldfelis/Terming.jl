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

function parse_single_char_sequence(sequence::Char)
    if sequence == '\n' || sequence == '\r' # ENTER
        return KeyPressedEvent(ENTER, CtlKeys[])
    elseif sequence == '\e' # ESC
        return KeyPressedEvent(ESC, CtlKeys[])
    elseif sequence == '\t' # TAB
        return KeyPressedEvent(TAB, CtlKeys[])
    elseif sequence == '\x7F' #BACKSPACE
        return KeyPressedEvent(BACKSPACE, CtlKeys[])
    elseif sequence == '\0' # NULL
        return KeyPressedEvent(NULL, CtlKeys[])
    elseif any(isequal(sequence), Char(0x01):Char(0x1A)) # CTRL + key
        return KeyPressedEvent(Char(UInt8(sequence)-0x01+UInt8('a')), [CTRL])
    elseif any(isequal(sequence), Char(0x0C):Char(0x1F)) # CTRL + key
        return KeyPressedEvent(Char(UInt8(sequence)-0x1C+UInt8('4')), [CTRL])
    else # single char
        return KeyPressedEvent(sequence, CtlKeys[])
    end
end

function parse_esc_leaded_sequence(sequence::String, state::Int)
    (c, state) = iterate(sequence, state)
    if c == 'O' # F1 - F4
        return parse_xterm_f1_2_f4(sequence, state)
    elseif c == '[' # Some CSI sequence
        return parse_csi(sequence, state)
    elseif iterate(sequence, state) === nothing # ALT + key
        e = parse_single_char_sequence(c)
        push!(e.ctls, ALT)
        return e
    end

    return PasteEvent(sequence) # fallback
end

function parse_xterm_f1_2_f4(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return PasteEvent(sequence)) # fallback

    (c, state) = next
    if any(isequal(c), 'P':'S')
        return KeyPressedEvent(SpetialKeys(UInt8(c)-UInt8('P')), CtlKeys[])
    end

    return PasteEvent(sequence) # fallback
end

function parse_csi(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return PasteEvent(sequence)) # fallback

    if sequence[end] == '~' # vt sequence
        code_sequence = sequence[state:(end-1)]
        if ';' in code_sequence # with ctl keys
            # +------------------------------------------------------------------+
            # | the form of the sequence: "\e[<code>;<ctls_code>~" and code=1:35 |
            # +------------------------------------------------------------------+
            code, ctls_code = tryparse.(Int, split(code_sequence, ';'))
            (code === nothing || ctls_code === nothing) && (return PasteEvent(sequence))  # fallback
            ctls = parse_ctl_code(ctls_code)
            (ctls == [-1]) && (return PasteEvent(sequence))  # fallback
        else # without ctl keys
            # +------------------------------------------------------+
            # | the form of the sequence: "\e[<code>~" and code=1:35 |
            # +------------------------------------------------------+
            code = tryparse(Int, code_sequence)
            (code === nothing) && (return PasteEvent(sequence))  # fallback
            ctls = CtlKeys[]
        end

        return parse_vt_code(sequence, code, ctls=ctls)
    else # xterm sequence
        code_sequence = sequence[state:end]
        if ';' in code_sequence # with ctl keys
            # +-----------------------------------------------------------------+
            # | the form of the sequence: "\e[1;<ctls_code><code>" and code=A:Z |
            # +-----------------------------------------------------------------+
            id, code_sequence = split(code_sequence, ';')
            (id != "1" || length(code_sequence) != 2) && (return PasteEvent(sequence))  # fallback

            # determing key code
            c = code_sequence[2]
            if any(isequal(c), 'P':'S') # F1 - F4 with ctl keys have the same form
                code = Int(c)-Int('P') # code=1:3, matches the enum F1 - F4
            else
                code = Int(c)
            end

            # construct CtlKeys array
            ctls_code = tryparse(Int, string(code_sequence[1]))
            (ctls_code === nothing) && (return PasteEvent(sequence)) # fallback
            ctls = parse_ctl_code(ctls_code)
            (ctls == [-1]) && (return PasteEvent(sequence))  # fallback
        else # without ctl keys (not including F1 - F4)
            # +----------------------------------------------------+
            # | the form of the sequence: "\e[<code>" and code=A:Z |
            # +----------------------------------------------------+
            (length(code_sequence) != 1) && (return PasteEvent(sequence))  # fallback

            # determing key code
            code = Int(code_sequence[1])

            # construct CtlKeys array
            ctls = CtlKeys[]
        end

        return parse_xterm_code(sequence, code, ctls=ctls)
    end
end

function parse_vt_code(sequence::String, code::Int; ctls=CtlKeys[])
    if code in 1:6 # HOME INSERT DELETE END PAGEUP PAGEDOWN
        enum_bias = 11
        return KeyPressedEvent(SpetialKeys(code+enum_bias), ctls)
    elseif code == 7 # HOME
        return KeyPressedEvent(HOME, ctls)
    elseif code == 8 # END
        return KeyPressedEvent(END, ctls)
    elseif code in 11:15 # F1 - F5
        return KeyPressedEvent(SpetialKeys(code-11), ctls)
    elseif code in 17:21 # F6 - f10
        return KeyPressedEvent(SpetialKeys(code-12), ctls)
    elseif code in 23:24 # F11 - F12
        return KeyPressedEvent(SpetialKeys(code-13), ctls)
    end

    return PasteEvent(sequence) # fallback
end

function parse_xterm_code(sequence::String, code::Int; ctls=CtlKeys[])
    if code in Int('A'):Int('D') || code == Int('Z') # UP DOWN RIGHT LEFT BACKTAB
        return KeyPressedEvent(SpetialKeys(code), ctls)
    elseif code == Int('F') # END
        return KeyPressedEvent(END, ctls)
    elseif code == Int('G') # Keypad 5
        return KeyPressedEvent('5', ctls)
    elseif code == Int('H') # HOME
        return KeyPressedEvent(HOME, ctls)
    elseif code in 0:3 # F1 - F4 with ctl keys have the same form
        return KeyPressedEvent(SpetialKeys(code), ctls)
    end

    return PasteEvent(sequence) # fallback
end

function parse_ctl_code(code::Int)
    if  code in [2, 3, 5]
        return [CtlKeys(code)]
    elseif code == 4
        return [SHIFT, ALT]
    elseif code == 6
        return [SHIFT, CTRL]
    elseif code == 7
        return [CTRL, ALT]
    elseif code == 8
        return [SHIFT, CTRL, ALT]
    end

    return [-1] # fallback
end
