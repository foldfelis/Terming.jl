struct InputListener
    pipeline::Vector{Channel}
end

function InputListener(size=Inf)
    sequence_queue = Channel{String}(size, spawn=true) do ch
        while true
            sequence = T.read_strem()
            put!(ch, sequence)
        end
    end
    event_queue = Channel{T.Event}(size, spawn=true) do ch
        while true
            sequence = take!(sequence_queue)
            put!(ch, T.parse_sequence(sequence))
        end
    end

    return InputListener([sequence_queue, event_queue])
end
