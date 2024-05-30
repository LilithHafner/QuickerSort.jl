# This file is adapted from `naive_hoar.jl` which, in turn, is adapted from Julia's standard library

function insertion_sort!(src, lo, hi, rev, v)
    src === v || copyto!(v, lo, src, lo, hi-lo+1)
    rev && reverse!(v, lo, hi)
    insertion_sort!(v, lo, hi)
end

# partition!
#
# select a pivot, and partition v according to the pivot

function hafner_partition!(dst::AbstractVector, src::AbstractVector, lo::Integer, hi::Integer, rev::Bool)
    # The pivot selection used in Hoar and Lomuto implementations is unstable so we have to use a different approach here
    pivot_index = mod(hash(lo), lo:hi)
    pivot = src[pivot_index]

    large_values = 0
    @inbounds for i in lo:pivot_index-1
        x = src[i]
        fx = rev ? !isless(x, pivot) : isless(pivot, x)
        dst[(fx ? hi : i) - large_values] = x
        large_values += fx
    end
    @inbounds for i in pivot_index+1:hi
        x = src[i]
        fx = rev ? isless(pivot, x) : !isless(x, pivot)
        dst[(fx ? hi : i-1) - large_values] = x
        large_values += fx
    end

    new_pivot_index = hi-large_values

    # dst[k] >= pivot for k > new_pivot_index
    # dst[i] <= pivot for i < new_pivot_index
    return pivot, new_pivot_index
end

naive_hafner_quicksort!(v::AbstractVector) = naive_hafner_quicksort!(v, firstindex(v), lastindex(v))
naive_hafner_quicksort!(v::AbstractVector, lo::Integer, hi::Integer) = naive_hafner_quicksort!(similar(v), v, lo, hi, false, v)
function naive_hafner_quicksort!(dst::AbstractVector, src::AbstractVector, lo::Integer, hi::Integer, rev::Bool, v::AbstractVector)
    @inbounds while lo <= hi
        hi-lo <= SMALL_THRESHOLD && return insertion_sort!(src, lo, hi, rev, v)
        pivot, j = hafner_partition!(dst, src, lo, hi, rev)
        src, dst = dst, src
        @inbounds v[j] = pivot
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo <= (j-1) && naive_hafner_quicksort!(dst, src, lo, j-1, rev, v)
            lo = j+1
            rev = !rev
        else
            j+1 <= hi && naive_hafner_quicksort!(dst, src, j+1, hi, !rev, v)
            hi = j-1
        end
    end
    return v
end
