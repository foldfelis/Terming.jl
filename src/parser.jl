export parse_queue

function parse_queue(queue::String)
    err = "Could not parse an event"

    queue = [c for c in queue]
    events = String[]
    while length(queue) > 0

        c = popfirst!(queue)

        if c == '\e'
            push!(events, "This is an escape character, leading a control sequence.")
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
