
# This file is adapted from Julia's standard library implementation of InsertionSort
# https://github.com/JuliaLang/julia/blob/6a10d03c5ec7ceaace325e2379ac1f0cac7c3761/base/sort.jl#L834-L851

const SMALL_THRESHOLD = 20

function insertion_sort!(v::AbstractVector, lo::Int, hi::Int)
    lo_plus_1 = (lo + 1)::Integer
    @inbounds for i = lo_plus_1:hi
        j = i
        x = v[i]
        while j > lo
            y = v[j-1]
            if !((x < y)::Bool)
                break
            end
            v[j] = y
            j -= 1
        end
        v[j] = x
    end
    return v
end
