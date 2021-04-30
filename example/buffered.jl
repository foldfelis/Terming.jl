using Terming

function main()
    # set term size and clear
    Terming.displaysize(20, 75); Terming.clear()
    # move cursor to (row=2, col=2)
    Terming.cmove(2, 2)

    # +----------------+
    # | without buffer |
    # +----------------+
    str = "This string will be finished printing once the calculations are..."
    Terming.print(str)
    sleep(1) # fake time consuming calculation
    Terming.println(" done!!")

    # move cursor to the beginning of next two line; move to col=2
    Terming.cmove_line_down(2); Terming.cmove_col(2)

    # +-------------+
    # | with buffer |
    # +-------------+
    Terming.buffered() do buffer
        str = "This string will be finished printing once the calculations are"
        Terming.print(buffer, str)
        sleep(1) # fake time consuming calculation
        Terming.println(buffer, " done!!")
    end

    return
end

main()
