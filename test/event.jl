@testset "event" begin
    event = T.KeyPressedEvent(
        'c',
        [T.CTRL]
    )
    @test event.key == 'c'
    @test T.CTRL in event.ctls

    event = T.PasteEvent("Apple is good to eat")
    @test event.content == "Apple is good to eat"
end
