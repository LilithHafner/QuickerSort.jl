using QuickerSort
using Test
using Aqua

@testset "QuickerSort.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(QuickerSort)
    end
    # Write your tests here.
end
