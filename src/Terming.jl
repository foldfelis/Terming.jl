module Terming

    include("terminal.jl")
    include("event.jl")
    include("parser.jl")
    include("dev_tools.jl")

    export term, in_stream, out_stream, err_stream
    export set_term!

    term = nothing
    in_stream = nothing
    out_stream = nothing
    err_stream = nothing

    function __init__()
        set_term!(init_term())
    end

    function set_term!(t::REPL.Terminals.UnixTerminal)
        global term = t
        global in_stream = t.in_stream
        global out_stream = t.out_stream
        global err_stream = t.err_stream
    end

end
