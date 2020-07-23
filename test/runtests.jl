using REPL
using Test

using Terming
const T = Terming

@testset "manual" begin

    manual_debug_mode = false
    (manual_debug_mode) && include("manual.jl")

end

@testset "Terming.jl" begin

    T.set_term!(T.PseudoTerminal(
        Base.BufferStream(), Base.BufferStream(), Base.BufferStream()
    ))

    include("terminal.jl")
    include("event.jl")
    include("parser.jl")

end
