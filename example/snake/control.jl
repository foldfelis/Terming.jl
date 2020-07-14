struct App
    size::Tuple{Int, Int}
    quit_sequence::String
    event_queue::Channel
    model::Model
    view::View
end

function init_term(app::App)
    run(`clear`)
    h, w = app.size
    T.displaysize(h, w)
    T.cshow(false)
    T.raw!(true)
end

function reset_term(::App)
    T.raw!(false)
    T.cshow()
    return
end

@enum ChannelSignals begin
    CLOSE
end

function init_event_queue(; quit_sequence="\e", size=Inf)
    sequence_queue = Channel{Union{String, ChannelSignals}}(size)
    Base.Threads.@spawn begin
        while true
            sequence = T.read_buffer()
            put!(sequence_queue, sequence)

            if sequence === quit_sequence
                put!(sequence_queue, CLOSE)
                break
            end
        end
    end

    event_queue = Channel{Union{T.Event, ChannelSignals}}(size)
    Base.Threads.@spawn begin
        while true
            sequence = take!(sequence_queue)

            if sequence === CLOSE
                put!(event_queue, QuitEvent())
                close(sequence_queue)
                break
            end

            put!(event_queue, parse_sequence(sequence))
        end
    end

    return sequence_queue, event_queue
end

function emit_quit_event(app::App)
    T.cmove_line_last()
    println(T.term.out_stream, "\nYou Lose")
    put!(app.event_queue, QuitEvent())
end

function handle_quit(app::App)
    keep_running = false
    close(app.event_queue)

    T.cmove_line_last()
    println(T.term.out_stream, "\nShutted down...")

    return keep_running
end

function handle_event(app::App)
    snake = app.model

    is_running = true
    while is_running
        e = take!(app.event_queue)
        if e === T.QuitEvent()
            is_running = handle_quit(app)
        elseif e === LossEvent()
            emit_quit_event(app)
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
        end
    end
end

function Base.run(app::App)
    init_term(app)
    paint(app.view)
    handle_event(app)
    reset_term(app)
end
