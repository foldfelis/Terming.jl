export PseudoTerminal, pseudo_input

# +-----------------+
# | pseudo terminal |
# +-----------------+

mutable struct PseudoTerminal <: REPL.Terminals.UnixTerminal
    term_type::String
    in_stream::Base.IO
    out_stream::Base.IO
    err_stream::Base.IO
    raw::Bool
end

PseudoTerminal(in::Base.IO, out::Base.IO, err::Base.IO) = PseudoTerminal(
    get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"),
    in, out, err,
    false
)

REPL.Terminals.raw!(t::PseudoTerminal, raw::Bool) = (t.raw = raw)

REPL.Terminals.displaysize(::PseudoTerminal) = (24, 80)

pseudo_input(key::String, t=term) = Base.print(t.in_stream, key)
