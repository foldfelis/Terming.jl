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
#         pipeline::Vector{Channel}
#     end

#     get_event_queue(app::App) = app.pipeline[end]

#     function init_pipeline(size=Inf)
#         sequence_queue = Channel{String}(size, spawn=true) do ch
#             while true
#                 sequence = T.read_strem()
#                 put!(ch, sequence)
#             end
#         end
#         event_queue = Channel{T.Event}(size, spawn=true) do ch
#             while true
#                 sequence = take!(sequence_queue)
#                 put!(ch, T.parse_sequence(sequence))
#             end
#         end

#         return [sequence_queue, event_queue]
#     end

#     function initial_app()
#         pipeline = init_pipeline()
#         app = App(pipeline)

#         return app
#     end

#     emit_quit_event(app::App) = put!(get_event_queue(app), T.QuitEvent())

#     function handle_quit(app::App)
#         keep_running = false
#         foreach(close, app.pipeline)
#         println(T.term.out_stream, "Shutted down...")

#         return keep_running
#     end

#     function handle_event(app::App)
#         T.raw!(true)
#         is_running = true
#         while is_running
#             e = take!(get_event_queue(app))
#             @show e

#             # sleep(1) # previous time-consuming calculation
#             if e === T.QuitEvent()
#                 is_running = handle_quit(app)
#             elseif e === T.KeyPressedEvent(T.ESC)
#                 emit_quit_event(app)
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
