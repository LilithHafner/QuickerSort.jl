# This file is adapted from `naive_hoar.jl` which, in turn, is adapted from Julia's standard library

# selectpivot!
#
# Given 3 locations in an array (lo, mi, and hi), sort v[lo], v[mi], v[hi] and
# choose the middle value as a pivot
#
# Upon return, the pivot is in v[lo], and v[hi] is guaranteed to be
# less than or equal to the the pivot

@inline function lomuto_selectpivot!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds begin
        mi = Base.midpoint(lo, hi)

        # sort v[hi] <= v[lo] <= v[mi] such that the pivot is immediately in place
        # and a sentinel is at the end
        if v[lo] < v[hi]
            v[hi], v[lo] = v[lo], v[hi]
        end

        if v[mi] < v[lo]
            if v[mi] < v[hi]
                v[mi], v[lo], v[hi] = v[lo], v[hi], v[mi]
            else
                v[mi], v[lo] = v[lo], v[mi]
            end
        end

        # return the pivot
        return v[lo]
    end
end

# partition!
#
# select a pivot, and partition v according to the pivot

function lomuto_partition!(v::AbstractVector, lo::Integer, hi::Integer)
    pivot = lomuto_selectpivot!(v, lo, hi)
    # pivot == v[lo], v[mi] >= pivot, v[hi] <= pivot
    i = lo+1
    @inbounds while v[i] < pivot; i += 1; end # This won't oob because v[mi] >= pivot
    j = i+1
    @inbounds while true
        while pivot < v[j]; j += 1; end # This won't oob because v[hi] <= pivot
        j == hi && break
        v[i], v[j] = v[j], v[i]
        i += 1
    end
    @inbounds v[lo], v[i-1] = v[i-1], v[lo]

    # v[j] == pivot
    # v[k] >= pivot for k > j
    # v[i] <= pivot for i < j
    return j
end

naive_lomuto_quicksort!(v::AbstractVector) = naive_lomuto_quicksort!(v, firstindex(v), lastindex(v))
function naive_lomuto_quicksort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return insertion_sort!(v, lo, hi)
        j = lomuto_partition!(v, lo, hi)
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo < (j-1) && naive_lomuto_quicksort!(v, lo, j-1)
            lo = j+1
        else
            j+1 < hi && naive_lomuto_quicksort!(v, j+1, hi)
            hi = j-1
        end
    end
    return v
end