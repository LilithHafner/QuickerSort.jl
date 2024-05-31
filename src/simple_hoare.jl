# This file is adapted from Julia's standard library implementation of QuickSort using hoare partitioning
# https://github.com/JuliaLang/julia/blob/6a10d03c5ec7ceaace325e2379ac1f0cac7c3761/base/sort.jl#L2320-L2389

# selectpivot!
#
# Given 3 locations in an array (lo, mi, and hi), sort v[lo], v[mi], v[hi] and
# choose the middle value as a pivot
#
# Upon return, the pivot is in v[lo], and v[hi] is guaranteed to be
# greater than the pivot

@inline function selectpivot!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds begin
        mi = Base.midpoint(lo, hi)

        # sort v[mi] <= v[lo] <= v[hi] such that the pivot is immediately in place
        if isless(v[lo], v[mi])
            v[mi], v[lo] = v[lo], v[mi]
        end

        if isless(v[hi], v[lo])
            if isless(v[hi], v[mi])
                v[hi], v[lo], v[mi] = v[lo], v[mi], v[hi]
            else
                v[hi], v[lo] = v[lo], v[hi]
            end
        end

        # return the pivot
        return v[lo]
    end
end

# partition!
#
# select a pivot, and partition v according to the pivot

function partition!(v::AbstractVector, lo::Integer, hi::Integer)
    pivot = selectpivot!(v, lo, hi)
    # pivot == v[lo], v[hi] > pivot
    i, j = lo, hi
    @inbounds while true
        i += 1; j -= 1
        while isless(v[i], pivot); i += 1; end
        while isless(pivot, v[j]); j -= 1; end
        i >= j && break
        v[i], v[j] = v[j], v[i]
    end
    v[j], v[lo] = pivot, v[j]

    # v[j] == pivot
    # v[k] >= pivot for k > j
    # v[i] <= pivot for i < j
    return j
end

simple_hoare_quicksort!(v::AbstractVector) = simple_hoare_quicksort!(v, firstindex(v), lastindex(v))
function simple_hoare_quicksort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return insertion_sort!(v, lo, hi)
        j = partition!(v, lo, hi)
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo < (j-1) && simple_hoare_quicksort!(v, lo, j-1)
            lo = j+1
        else
            j+1 < hi && simple_hoare_quicksort!(v, j+1, hi)
            hi = j-1
        end
    end
    return v
end
