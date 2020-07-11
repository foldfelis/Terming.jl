export SpetialKeys, CtlKeys
export Event, KeyPressedEvent, PasteEvent

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

struct PasteEvent <: Event
    content::String
end
