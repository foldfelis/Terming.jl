using REPL
using Test

using Terming
const T = Terming

export FakeTerminal, fake_input

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

fake_input(key::String; t=T.term) = print(t.in_stream, key)

# @testset "manual" begin

#     quit_key = "\033"

#     queue = Channel{String}(64)
#     Base.Threads.@spawn begin
#         while true
#             key = T.read_buffer()
#             put!(queue, key)
#             (key == quit_key) && break
#         end
#     end

#     T.raw!(true)
#     is_running = true
#     while is_running
#         c = ""
#         c = take!(queue)
#         @show c

#         # sleep(1) # previous time-consuming calculation
#         if c == quit_key
#             is_running = false
#             println(T.term.out_stream, "Shutted down... ")
#         end
#         # sleep(1) # next time-consuming calculation
#     end
#     T.raw!(false)

# end

@testset "Terming.jl" begin

    T.set_term!(FakeTerminal(
        Base.BufferStream(), Base.BufferStream(), Base.BufferStream()
    ))

    include("terminal.jl")
    include("parser.jl")

end
