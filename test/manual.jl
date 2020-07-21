struct QuitEvent <: T.Event end

Base.show(io::IO, ::QuitEvent) = Base.print(io, "QuitEvent")

struct App
    pipeline::Vector{Channel}
end

get_event_queue(app::App) = app.pipeline[end]

function init_pipeline(size=Inf)
    sequence_queue = Channel{String}(size, spawn=true) do ch
        while true
            sequence = T.read_stream()
            put!(ch, sequence)
        end
    end
    event_queue = Channel{T.Event}(size, spawn=true) do ch
        while true
            sequence = take!(sequence_queue)
            put!(ch, T.parse_sequence(sequence))
        end
    end

    return [sequence_queue, event_queue]
end

function initial_app()
    pipeline = init_pipeline()
    app = App(pipeline)

    return app
end

emit_quit_event(app::App) = put!(get_event_queue(app), QuitEvent())

function handle_quit(app::App)
    keep_running = false
    foreach(close, app.pipeline)
    T.println("Shutted down...")

    return keep_running
end

function handle_event(app::App)
    T.raw!(true)
    is_running = true
    while is_running
        e = take!(get_event_queue(app))
        @show e

        # sleep(1) # previous time-consuming calculation
        if e === QuitEvent()
            is_running = handle_quit(app)
        elseif e === T.KeyPressedEvent(T.ESC)
            emit_quit_event(app)
        end
        # sleep(1) # next time-consuming calculation
    end
    T.raw!(false)
end

function debug_manually()
    app = initial_app()
    handle_event(app)
end

debug_manually()
