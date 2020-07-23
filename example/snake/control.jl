struct InputListener
    pipeline::Vector{Channel}
end

function InputListener(size=Inf)
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

    return InputListener([sequence_queue, event_queue])
end

struct QuitEvent <: T.Event end
Base.show(io::IO, ::QuitEvent) = Base.print(io, "QuitEvent")

struct App
    size::Tuple{Int, Int}
    listener::InputListener
    model::Model
    view::View
end

event_queue(app::App) = app.listener.pipeline[end]

function init_term(app::App)
    T.cshow(false)
    Sys.iswindows() ? T.clear() : T.alt_screen(true)
    h, w = app.size; T.displaysize(h+3, w)
    T.raw!(true)
end

function reset_term(::App)
    T.raw!(false)
    sleep(1)
    !(Sys.iswindows()) && T.alt_screen(false)
    T.cshow()

    return
end

emit_quit_event(app::App) = put!(event_queue(app), QuitEvent())

function handle_lose(app::App)
    T.cmove_line_last()
    paint(app.view, state=:lose)
    emit_quit_event(app)
end

function handle_quit(app::App)
    keep_running = false
    foreach(close, app.listener.pipeline)

    T.cmove_line_last()
    T.cmove_up(2)
    T.println("Shutted down...")

    return keep_running
end

function handle_event(app::App)
    snake = app.model
    auto_move(snake)

    is_running = true
    while is_running
        e = take!(event_queue(app))
        if e === QuitEvent()
            is_running = handle_quit(app)
        elseif e === LossEvent()
            handle_lose(app)
        elseif e === UpdateEvent()
            paint(app.view)
        elseif e === T.KeyPressedEvent(T.UP)
            move(snake, :up)
        elseif e === T.KeyPressedEvent(T.DOWN)
            move(snake, :down)
        elseif e === T.KeyPressedEvent(T.RIGHT)
            move(snake, :right)
        elseif e === T.KeyPressedEvent(T.LEFT)
            move(snake, :left)
        elseif e === T.KeyPressedEvent(T.ESC)
            emit_quit_event(app)
        end
    end
end

function Base.run(app::App)
    init_term(app)
    paint(app.view)
    handle_event(app)
    reset_term(app)
end
