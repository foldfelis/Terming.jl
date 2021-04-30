using Terming

function main()
    # set term size
    Terming.displaysize(20, 75)
    # switch to alternate screen
    Terming.alt_screen(true)

    Terming.cmove(1, 1)
    Terming.println("Terminal is now switched to the alternate screen mode.")
    Terming.println("Press ENTER to switch back."); readline()

    # switch back from alternate screen
    Terming.alt_screen(false)

    return
end

main()
