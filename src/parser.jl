export parse_sequence

function parse_sequence(sequence::String)
    if length(sequence) == 1
        return parse_single_char_sequence(Char(sequence[1]))
    end

    return parse_esc_leaded_sequence(Vector{Char}(sequence))
end

function parse_single_char_sequence(sequence::Char)
    if sequence == '\n' || sequence == '\r'
        return "'Enter' pressed"
    elseif sequence == '\e'
        return "'ESC' pressed"
    elseif sequence == '\t'
        return "'Tab' pressed"
    elseif sequence == '\x7F'
        return "'Backspace' pressed"
    elseif sequence == '\0'
        return "'Null' pressed"
    elseif sequence in [Char(c) for c in 0x01:0x1A]
        return "'Ctrl+$(Char(UInt8(sequence)-0x01+UInt8('a')))' pressed"
    elseif sequence in [Char(c) for c in 0x1C:0x1F]
        return "'Ctrl+$(Char(UInt8(sequence)-0x1C+UInt8('4')))' pressed"
    else
        return "'$(sequence)' pressed"
    end
end

function parse_esc_leaded_sequence(sequence::Vector{Char})
    err = "Could not parse an event"

    while length(sequence) > 0
        c = popfirst!(sequence)
        if c == '\e'
            c = popfirst!(sequence)
            if c == '0' # F1 - F4
                c = popfirst!(sequence)
                if c in [Char(i) for i=UInt8('P'):UInt8('S')]
                    return "'F$(0x01+UInt8(c)-UInt8('P'))' pressed"
                else
                    throw(err)
                end
            elseif c == '[' # Some CSI sequence
                return "Some CSI sequence"
            else
                return "'ALT+$(c)' pressed"
            end
        else
            throw(err)
        end
    end
end
