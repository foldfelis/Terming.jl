module Terming

    include("event.jl")
    include("parser.jl")
    include("terminal.jl")

    export set_term!

    term = nothing
    __init__() = (global term = init_term())

    set_term!(t::REPL.Terminals.UnixTerminal) = (global term = t)

end
