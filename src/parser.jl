export parse_sequence

function parse_sequence(sequence::String)
    if length(sequence) == 1
        return parse_single_char_sequence(Char(sequence[1]))
    end

    (c, state) = iterate(sequence)
    if c == '\e'
        return parse_esc_leaded_sequence(sequence, state)
    end

    return sequence # fallback
end

function parse_single_char_sequence(sequence::Char)
    if sequence == '\n' || sequence == '\r'
        return "Enter"
    elseif sequence == '\e'
        return "ESC"
    elseif sequence == '\t'
        return "Tab"
    elseif sequence == '\x7F'
        return "Backspace"
    elseif sequence == '\0'
        return "Null"
    elseif sequence in [Char(c) for c in 0x01:0x1A]
        return "Ctrl+$(Char(UInt8(sequence)-0x01+UInt8('a')))"
    elseif sequence in [Char(c) for c in 0x1C:0x1F]
        return "Ctrl+$(Char(UInt8(sequence)-0x1C+UInt8('4')))"
    else # single char
        return "$(sequence)"
    end
end

function parse_esc_leaded_sequence(sequence::String, state::Int)
    (c, state) = iterate(sequence, state)
    if c == 'O' # F1 - F4
        return parse_f1_2_f4(sequence, state)
    elseif c == '[' # Some CSI sequence
        return parse_csi(sequence, state)
    elseif iterate(sequence, state) === nothing
        c = parse_single_char_sequence(c)
        return "ALT+$(c)"
    end

    return sequence # fallback
end

function parse_f1_2_f4(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return sequence)

    (c, state) = next
    if c in [Char(i) for i=UInt8('P'):UInt8('S')]
        return "F$(0x01+UInt8(c)-UInt8('P'))"
    end

    return sequence # fallback
end

function parse_csi(sequence::String, state::Int)
    next = iterate(sequence, state)
    (next === nothing) && (return sequence)

    (c, state) = next
    next = iterate(sequence, state)
    if next === nothing # Direction keys
        return parse_direction_code(sequence, c)
    elseif sequence[end] == '~'
        if ';' in sequence  # F5 - F12 and spetial keys with ctl key
            splitted_sci = split(sequence[(state-1):end-1], ';')
            key_code = parse(Int, string(splitted_sci[1]))
            ctl_code = splitted_sci[2][1]

            key = ""
            if key_code == 1 || key_code == 7
                key = "Home"
            elseif key_code == 2
                key = "Insert"
            elseif key_code == 3
                key = "Delete"
            elseif key_code == 4 || key_code == 8
                key = "End"
            elseif key_code == 5
                key = "PageUp"
            elseif key_code == 6
                key = "PageDown"
            elseif key_code in 11:15
                key = "F$(key_code-10)"
            elseif key_code in 17:21
                key = "F$(key_code-11)"
            elseif key_code in 23:24
                key = "F$(key_code-12)"
            end
            ctl = parse_ctl_code(ctl_code)

            return "$(ctl)+$(key)"
        else # F5 - F12 and spetial keys
            key_code = parse(Int, sequence[(state-1):end-1])
            if key_code == 1 || key_code == 7
                return "Home"
            elseif key_code == 2
                return "Insert"
            elseif key_code == 3
                return "Delete"
            elseif key_code == 4 || key_code == 8
                return "End"
            elseif key_code == 5
                return "PageUp"
            elseif key_code == 6
                return "PageDown"
            elseif key_code in 11:15
                return "F$(key_code-10)"
            elseif key_code in 17:21
                return "F$(key_code-11)"
            elseif key_code in 23:24
                return "F$(key_code-12)"
            end
        end
    elseif ';' in sequence
        splitted_sci = split(sequence[(state-1):end], ';')
        if splitted_sci[1] == "1"
            ctl_code = splitted_sci[2][1]
            ctl = parse_ctl_code(ctl_code)
            f_code = splitted_sci[2][2]
            if f_code in [Char(i) for i=UInt8('P'):UInt8('S')] # ctl key with F1 - F4
                return "$(ctl)+F$(0x01+UInt8(f_code)-UInt8('P'))"
            elseif f_code in ['A', 'B', 'C', 'D', 'H', 'F', 'Z'] # Direction keys
                return "$(ctl)+$(parse_direction_code(sequence, f_code))"
            end
        end
    end

    return sequence # fallback
end

function parse_direction_code(sequence::String, code::AbstractChar)
    if code == 'A'
        return "Up"
    elseif code == 'B'
        return "Down"
    elseif code == 'C'
        return "Right"
    elseif code == 'D'
        return "Left"
    elseif code == 'H'
        return "Home"
    elseif code == 'F'
        return "End"
    elseif code == 'Z'
        return "BackTab"
    end

    return sequence # fallback
end

function parse_ctl_code(code::Char)
    ctl = ""
    if code == '2'
        ctl = "Shift"
    elseif code == '3'
        ctl = "ALT"
    elseif code == '4'
        ctl = "Shift+ALT"
    elseif code == '5'
        ctl = "Ctrl"
    elseif code == '6'
        ctl = "Shift+Ctrl"
    elseif code == '7'
        ctl = "ALT+Ctrl"
    elseif code == '8'
        ctl = "Shift+ALT+Ctrl"
    end

    return ctl
end
