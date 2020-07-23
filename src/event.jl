export SpecialKey, AdjointKey
export Event, KeyPressedEvent, PasteEvent
export match

@enum SpecialKey begin
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

@enum AdjointKey begin
    SHIFT = 2
    CTRL = 3
    SHIFT_ALT = 4
    ALT = 5
    SHIFT_CTRL = 6
    CTRL_ALT = 7
    SHIFT_CTRL_ALT = 8
    NO_ADJOINT = -1
end

abstract type Event end

KeyboardKey = Union{Char, SpecialKey}

struct KeyPressedEvent <: Event
    key::KeyboardKey
    adjoint_key::AdjointKey
end

KeyPressedEvent(key::KeyboardKey) = KeyPressedEvent(key, NO_ADJOINT)

function Base.show(io::IO, e::KeyPressedEvent)
    adjoint_key = (e.adjoint_key === NO_ADJOINT) ? "" : "$(string.(e.adjoint_key))+"
    Base.print(io, "KeyPressedEvent($(adjoint_key)'$(string(e.key))')")
end

struct PasteEvent <: Event
    content::String
end

Base.show(io::IO, e::PasteEvent) = Base.print(io, "PasteEvent(\"$(e.content)\")")
