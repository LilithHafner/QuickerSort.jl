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
            let v = rand(len)
                f(copy(v)) == sort(v) || fail(v, "Correctness")
            end
        end

        let v = rand(1:10, len)
            f(copy(v)) == sort(v) || fail(v, "Correctness")
        end

        allow_unstable || let v = Div10.(rand(1:100, len))
            f(copy(v)) == sort(v) || fail(v, "Stability")
        end
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
    @test test(QuickerSort.simple_hafner_quicksort!)
    @test_throws ErrorException test(QuickerSort.simple_lomuto_quicksort!)
    @test_throws ErrorException test(QuickerSort.simple_hoare_quicksort!)
    @test test(QuickerSort.simple_lomuto_quicksort!, allow_unstable=true)
    @test test(QuickerSort.simple_hoare_quicksort!, allow_unstable=true)
end
