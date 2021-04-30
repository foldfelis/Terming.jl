using Terming

function main()
    # set term size and clear
    Terming.displaysize(20, 75); Terming.clear()
    # move cursor to (row=6, col=10)
    Terming.cmove(6, 10)
    # save current position
    Terming.csave()
    Terming.print("This string is printed at (row=6, col=10)")
    # restore saved position
    Terming.crestore()
    # move cursor down
    Terming.cmove_down()
    Terming.print("This string is printed at next line, with same col")
    # move cursor to the beginning of next line
    Terming.cmove_line_down()
    Terming.print("This string is printed at the beginning of next line")
    # move cursor to last line
    Terming.cmove_line_last()

    return
end

main()
