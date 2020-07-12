@testset "event" begin

    event = T.KeyPressedEvent('c', [T.CTRL])
    @test event.key === 'c'
    @test T.CTRL in event.ctls

    event = T.KeyPressedEvent(T.ESC)
    @test event.key === T.ESC
    @test event.ctls == T.CtlKeys[]

    event = T.PasteEvent("Apple is good to eat")
    @test event.content === "Apple is good to eat"

end

@testset "match" begin

    event = T.KeyPressedEvent('c', [T.CTRL])
    @test T.match(event, T.KeyPressedEvent('c', [T.CTRL]))

    event = T.PasteEvent("Paste Event")
    @test T.match(event, T.PasteEvent("Paste Event"))

end
