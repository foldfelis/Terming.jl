@testset "parser" begin

    fake_input("p")
    @show T.parse_queue(T.read_buffer())

    fake_input("😁")
    @show T.parse_queue(T.read_buffer())

    fake_input("\e\n\r\t\x7F\0😁Good")
    @show T.parse_queue(T.read_buffer())
end
