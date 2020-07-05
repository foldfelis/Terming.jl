export parse_queue

function parse_queue(queue::String)
    err = "Could not parse an event"

    queue = [c for c in queue]
    events = String[]
    while length(queue) > 0

        c = popfirst!(queue)

        if c == '\e'
            c = popfirst!(queue)
            if c == '0' # F1 - F4
                c = popfirst!(queue)
                if c in [Char(i) for i=Int('P'):Int('S')]
                    push!(events, "'F$(1+Int(c)-Int('P'))' pressed")
                else
                    throw(err)
                end
            elseif c == '['
                push!(events, "Some CSI sequence")
            else
                push!(events, "'ALT+$(c)' pressed")
            end
        elseif c == '\n' || c == '\r'
            push!(events, "'Enter' pressed")
        elseif c == '\t'
            push!(events, "'Tab' pressed")
        elseif c == '\x7F'
            push!(events, "'Backspace' pressed")
        # else if Ctrl
            #
        elseif c == '\0'
            push!(events, "'Null' pressed")
        else
            push!(events, "'$(c)' pressed")
        end

    end

    return events
end
