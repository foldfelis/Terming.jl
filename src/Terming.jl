module Terming

    include("terminal.jl")
    include("event.jl")
    include("parser.jl")

    export buffered_out_stream, term, in_stream, out_stream, err_stream, set_term!

    const buffered_out_stream = Base.BufferStream()

    term = nothing
    in_stream = nothing
    out_stream = nothing
    err_stream = nothing

    function __init__()
        init_term()
    end

    function set_term!(; t=init_term())
        global term = t
        global in_stream = t.in_stream
        global out_stream = t.out_stream
        global err_stream = t.err_stream
    end

end
