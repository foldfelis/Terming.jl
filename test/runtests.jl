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

#     struct App
#         event_queue::Channel
#     end

#     @enum ChannelSignals begin
#         CLOSE
#     end

#     function init_event_queue(;quit_sequence="\e", size=Inf)
#         sequence_queue = Channel{Union{String, ChannelSignals}}(size)
#         Base.Threads.@spawn begin
#             while true
#                 sequence = T.read_buffer()
#                 put!(sequence_queue, sequence)

#                 if sequence === quit_sequence
#                     put!(sequence_queue, CLOSE)
#                     break
#                 end
#             end
#         end

#         event_queue = Channel{Union{T.Event, ChannelSignals}}(size)
#         Base.Threads.@spawn begin
#             while true
#                 sequence = take!(sequence_queue)

#                 if sequence === CLOSE
#                     put!(event_queue, QuitEvent())
#                     close(sequence_queue)
#                     break
#                 end

#                 put!(event_queue, parse_sequence(sequence))
#             end
#         end

#         return sequence_queue, event_queue
#     end

#     function initial_app()
#         _, event_queue = init_event_queue()
#         app = App(event_queue)

#         return app
#     end

#     function handle_quit(app::App)
#         keep_running = false
#         close(app.event_queue)
#         println(T.term.out_stream, "Shutted down...")

#         return keep_running
#     end

#     function handle_event(app::App)
#         T.raw!(true)
#         is_running = true
#         while is_running
#             e = take!(app.event_queue)
#             @show e

#             # sleep(1) # previous time-consuming calculation
#             if e === T.QuitEvent()
#                 is_running = handle_quit(app)
#             end
#             # sleep(1) # next time-consuming calculation
#         end
#         T.raw!(false)
#     end

#     function debug_manually()
#         app = initial_app()
#         handle_event(app)
#     end

#     debug_manually()

# end

@testset "Terming.jl" begin

    T.set_term!(FakeTerminal(
        Base.BufferStream(), Base.BufferStream(), Base.BufferStream()
    ))

    include("terminal.jl")
    include("event.jl")
    include("parser.jl")

end
