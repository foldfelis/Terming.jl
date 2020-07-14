using Terming
const T = Terming

include("model.jl")
include("view.jl")
include("control.jl")

function init_app(term_size=(30, 80))
    # event queue
    _, event_queue = init_event_queue()

    # model
    ph, pw = term_size
    snake_model = SnakeModel(ph, pw, event_queue)

    # view
    snake_view = SnakeView(snake_model)
    form_view = FormView(term_size, [snake_view])

    app = App(term_size, "\e", event_queue, snake_model, form_view)

    return app
end

function main()
    app = init_app()
    run(app)
end

main()
