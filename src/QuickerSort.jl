module QuickerSort

include("insertion_sort.jl")
include("naive_hoar.jl")
include("naive_lomuto.jl")
include("naive_hafner.jl")
include("optimized_hafner.jl")


struct Div10
    n::Int
end
Base.isless(a::Div10, b::Div10) = a.n÷10 < b.n÷10
function test(f)
    for len in 1:1000
        for _ in 1:10
            v = rand(len)
            f(copy(v)) == sort(v) || fail(v, "Correctness")
        end

        v2 = Div10.(rand(1:100, len))
        f(copy(v2)) == sort(v2) || fail(v2, "Stability")
    end
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

end