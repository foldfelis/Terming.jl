using Terming
const T = Terming

const QUIT_SEQUENCE = "\e"
const EVENT_QUEUE = T.init_event_queue(QUIT_SEQUENCE)

include("view.jl")
include("model.jl")
include("control.jl")

const H, W = TERM_SIZE = (30, 80)
function design()
    snake = Snake()
    form = Form([snake])

    return View(form)
end

function main()
    run(App(design()))
end

main()
