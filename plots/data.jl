using Chairmarks, QuickerSort

const SIZES = Ref(round.(Int, exp.(LinRange(log(10), log(100_000_000), 20))))

function save_runtime_data(sizes=SIZES[]; seconds=300, seconds_per_trial=seconds/length(sizes)/7, path="runtime_data.csv")
    open(path, "w") do io
        println(io, "size,simple_lomuto,simple_hoare,simple_hafner,julia_hoare,julia_mergesort,julia_hafner,optimized_hafner")
        for (i, size) in enumerate(sizes)
            print('\r', size, " (", i, "/", length(sizes), ")")

            print(io, size)

            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_lomuto_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),
            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_hoare_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),
            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_hafner_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),

            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.QuickSort) seconds=seconds_per_trial).time), # hoare
            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.MergeSort) seconds=seconds_per_trial).time), # stable
            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.ScratchQuickSort()) seconds=seconds_per_trial).time), # hafner

            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.hafner_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time)

            println(io)
        end
    end
    println()
end


struct Count
    n::Int
    counter::Base.RefValue{Int}
end
Base.isless(a::Count, b::Count) = (a.counter[] += 1; a.n < b.n)
function count_comparisons(f, n, trials)
    counter = Ref(0)
    for _ in 1:trials
        x = rand(Int, n)
        f(Count.(x, Ref(counter)))
    end
    counter[]/trials
end
function min_count(n)
    Float64(log2(factorial(big(n))))
end


function save_count_data(sizes=SIZES[], path="count_data.csv")
    open(path, "w") do io
        println(io, "size,simple_lomuto,simple_hoare,simple_hafner,julia_hoare,julia_mergesort,julia_hafner,optimized_hafner,theoretical_minimum")
        for (i, size) in enumerate(sizes)
            print('\r', size, " (", i, "/", length(sizes), ")")

            print(io, size)

            trials = max(3, 10^7 ÷ size)
            print(io, ',', count_comparisons(QuickerSort.simple_lomuto_quicksort!, size, trials))
            print(io, ',', count_comparisons(QuickerSort.simple_hoare_quicksort!, size, trials))
            print(io, ',', count_comparisons(QuickerSort.simple_hafner_quicksort!, size, trials))

            print(io, ',', count_comparisons(v -> sort!(v, alg=Base.Sort.QuickSort), size, trials))
            print(io, ',', count_comparisons(v -> sort!(v, alg=Base.Sort.MergeSort), size, trials))
            print(io, ',', count_comparisons(v -> sort!(v, alg=Base.Sort.ScratchQuickSort()), size, trials))

            print(io, ',', count_comparisons(QuickerSort.hafner_quicksort!, size, trials))

            println(io, ',', min_count(size))
        end
    end
    println()
end
