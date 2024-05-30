using QuickerSort
using Test
using Aqua



struct Div10
    n::Int
end
Base.isless(a::Div10, b::Div10) = a.n÷10 < b.n÷10
function test(f; allow_unstable=false)
    for len in 1:1000
        for _ in 1:10
            v = rand(len)
            f(copy(v)) == sort(v) || fail(v, "Correctness")
        end

        v2 = Div10.(rand(1:100, len))
        allow_unstable || f(copy(v2)) == sort(v2) || fail(v2, "Stability")
    end
    true
end
function fail(v, message)
    global fail_example = v
    error(message * " " * string(length(v)))
end

struct Count
    n::Int
    counter::Base.RefValue{Int}
end
Base.isless(a::Count, b::Count) = (a.counter[] += 1; a.n < b.n)
function count_comparisons(f, n)
    counter = Ref(0)
    x = rand(Int, n)
    f(Count.(x, Ref(counter)))
    counter[]
end
function min_count(n)
    Float64(log2(factorial(big(n))))
end

@testset "QuickerSort.jl" begin
    # @testset "Code quality (Aqua.jl)" begin
    #     Aqua.test_all(QuickerSort)
    # end
    # Write your tests here.

    @test test(QuickerSort.hafner_quicksort!)
    @test test(QuickerSort.naive_hafner_quicksort!)
    @test_throws ErrorException test(QuickerSort.naive_lomuto_quicksort!)
    @test_throws ErrorException test(QuickerSort.naive_hoar_quicksort!)
    @test test(QuickerSort.naive_lomuto_quicksort!, allow_unstable=true)
    @test test(QuickerSort.naive_hoar_quicksort!, allow_unstable=true)
end
