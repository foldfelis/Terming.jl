export SpetialKeys, CtlKeys
export Event, KeyPressedEvent, PasteEvent
export match

@enum SpetialKeys begin
    # Function Keys match range 0:11
    F1
    F2
    F3
    F4
    F5
    F6
    F7
    F8
    F9
    F10
    F11
    F12

    # Key Code match range 12:17 (real code: 1:6(8))
    HOME # 1 or 7
    INSERT
    DELETE
    END # 4 or 8
    PAGEUP
    PAGEDOWN

    # Direction Keys
    UP = Int('A')
    DOWN = Int('B')
    RIGHT = Int('C')
    LEFT = Int('D')
    BACKTAB = Int('Z')

    ENTER
    ESC
    TAB
    BACKSPACE
    NULL
end

@enum CtlKeys begin
    SHIFT = 2
    CTRL = 3
    ALT = 5
end

abstract type Event end

struct KeyPressedEvent <: Event
    key::Union{Char, SpetialKeys}
    ctls::Vector{CtlKeys}
end

KeyPressedEvent(key::Union{Char, SpetialKeys}) = KeyPressedEvent(key, CtlKeys[])

function Base.show(io::IO, e::KeyPressedEvent)
    print(io, "KeyPressedEvent(")
    join(io, string.(e.ctls), "+")
    (length(e.ctls) > 0) && (print(io, "+"))
    print(io, "'$(string(e.key))')")
end

struct PasteEvent <: Event
    content::String
end

Base.show(io::IO, e::PasteEvent) = print(io, "PasteEvent(\"$(e.content)\")")

function match(e1::KeyPressedEvent, e2::KeyPressedEvent)
    (e1.key === e2.key) || return false
    for ctl in e1.ctls
        (ctl in e2.ctls) || return false
    end

    return true
end

match(e1::PasteEvent, e2::PasteEvent) = (e1.content === e2.content)
