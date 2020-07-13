struct App
    quit_sequence::String
    queue::Channel{T.Event}
    view::View
end

App(view::View) = App(QUIT_SEQUENCE, EVENT_QUEUE, view)

function init_term()
    run(`clear`)
    T.displaysize(H, W)
    T.cshow(false)
    T.raw!(true)
end

function reset_term()
    T.raw!(false)
    T.cshow()
    return
end

function handle_quit()
    T.cmove_line_last()
    println(T.term.out_stream, "\nShutting down... ")
end

function handle_event(app::App)
    up_event = T.KeyPressedEvent(T.UP)
    down_event = T.KeyPressedEvent(T.DOWN)
    right_event = T.KeyPressedEvent(T.RIGHT)
    left_event = T.KeyPressedEvent(T.LEFT)

    snake = app.view.form.components[1]

    auto_move(snake)

    is_running = true
    while is_running
        e = take!(app.queue)
        if e isa T.QuitEvent
            is_running = false
            handle_quit()
        elseif e isa UpdateEvent
            paint(app.view.form)
        elseif e isa T.KeyPressedEvent
            if T.match(e, up_event)
                move(snake, :up)
            elseif T.match(e, down_event)
                move(snake, :down)
            elseif T.match(e, right_event)
                move(snake, :right)
            elseif T.match(e, left_event)
                move(snake, :left)
            end
        end
    end
end

function Base.run(app::App)
    init_term()
    paint(app.view.form)
    handle_event(app)
    reset_term()
end
