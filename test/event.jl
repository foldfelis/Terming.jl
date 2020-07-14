@testset "event" begin

    event = T.QuitEvent()
    @test repr(event) === "QuitEvent"

    event = T.KeyPressedEvent('c', T.CTRL)
    @test event.key === 'c'
    @test event.ctl === T.CTRL
    @test event === T.KeyPressedEvent('c', T.CTRL)
    @test repr(event) === "KeyPressedEvent(CTRL+'c')"

    event = T.KeyPressedEvent(T.ESC)
    @test event.key === T.ESC
    @test event.ctl === T.NO_CTL
    @test repr(event) === "KeyPressedEvent('ESC')"

    event = T.PasteEvent("Paste Event")
    @test event.content === "Paste Event"
    @test event === T.PasteEvent("Paste Event")
    @test repr(event) === "PasteEvent(\"Paste Event\")"

end
