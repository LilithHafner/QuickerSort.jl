using Chairmarks, QuickerSort

function save_data(sizes=round.(Int, exp.(LinRange(log(10), log(100_000_000), 20))); seconds=40, seconds_per_trial=seconds/length(sizes)/7, path="data.csv")
    open(path, "w") do io
        println(io, "size,simple_lomuto,simple_hoare,simple_hafner,julia_hoare,julia_mergesort,julia_hafner,optimized_hafner")
        for size in sizes
            print(io, size)

            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_lomuto_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),
            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_hoare_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),
            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.simple_hafner_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time),

            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.QuickSort) seconds=seconds_per_trial).time), # hoare
            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.MergeSort) seconds=seconds_per_trial).time), # stable
            print(io, ',', (@b rand(Int,size),rand(Int,size) sort!(copyto!(_...), alg=Base.Sort.ScratchQuickSort()) seconds=seconds_per_trial).time), # hafner

            print(io, ',', (@b rand(Int,size),rand(Int,size) QuickerSort.hafner_quicksort!(copyto!(_...)) seconds=seconds_per_trial).time)

            println(io)
            println(size)
        end
    end
end
