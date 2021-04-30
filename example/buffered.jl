using Terming

function println_animation(str::String; delay::Real=0.05)
    # save current position of cursor
    Terming.csave()

    for c in str
        Terming.print(c)
        sleep(delay)
        delay *= 0.98
    end

    # restore position of cursor and move down
    Terming.crestore(); Terming.cmove_down()
end

function main()
    # set term size and clear
    Terming.displaysize(20, 80); Terming.clear()
    # move cursor to (row=2, col=2)
    Terming.cmove(2, 2)

    # +----------------+
    # | without buffer |
    # +----------------+
    discription = "The following string is blocked bue to the time-consuming calculations:"
    println_animation(discription)

    # save current position of cursor
    Terming.csave()

    str = "This string will be finished printing once the calculations are..."
    Terming.print(str)
    sleep(1) # fake time consuming calculation
    Terming.println(" done!!")

    # restore position of cursor and move down 2 row
    Terming.crestore(); Terming.cmove_down(2)

    # +-------------+
    # | with buffer |
    # +-------------+
    discription = "The following string is not blocked by the time-consuming calculations:"
    println_animation(discription)

    # save current position of cursor
    Terming.csave()

    Terming.buffered() do buffer
        str = "This string will be finished printing once the calculations are"
        Terming.print(buffer, str)
        sleep(1) # fake time consuming calculation
        Terming.println(buffer, " done!!")
    end

    # restore position of cursor and move down 2 row
    Terming.crestore(); Terming.cmove_down(2)

    return
end

main()
