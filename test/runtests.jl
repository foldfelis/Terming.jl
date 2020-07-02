using REPL
using Test

using Terming
const T = Terming

export FakeTerminal, fake_key_press

mutable struct FakeTerminal <: REPL.Terminals.UnixTerminal
    term_type::String
    in_stream::Base.IO
    out_stream::Base.IO
    err_stream::Base.IO
    raw::Bool
end

FakeTerminal(in::Base.IO, out::Base.IO, err::Base.IO) = FakeTerminal(
    get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"),
    in, out, err,
    false
)

function REPL.Terminals.raw!(t::FakeTerminal, raw::Bool)
    t.raw = raw
end

REPL.Terminals.displaysize(::FakeTerminal) = (24, 80)

fake_key_press(key::String; t=T.term) = print(t.in_stream, key)

@testset "Terming.jl" begin

    T.set_term!(FakeTerminal(
        Base.BufferStream(), Base.BufferStream(), Base.BufferStream()
    ))

    include("terminal.jl")

end
