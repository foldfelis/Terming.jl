using Terming

function main()
    # set term size and clear
    Terming.displaysize(20, 75); Terming.clear()

    # enable raw mode
    Terming.raw!(true)
    event = nothing
    while event != Terming.KeyPressedEvent(Terming.ESC)
        # read in_stream
        sequence = Terming.read_stream()
        # parse in_stream sequence to event
        event = Terming.parse_sequence(sequence)
        @show event
    end
    # disable raw mode
    Terming.raw!(false)

    return
end

main()
