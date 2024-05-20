using Base.Order

THRESHOLD() = 20

function _copyto!(dst::AbstractVector, src::AbstractVector, lo::Int, hi::Int)
    src === dst || copyto!(dst, lo, src, lo, hi-lo+1)
end

function smallsort_to!(dst::AbstractVector, src::AbstractVector, lo::Int, hi::Int, o::Ordering)
    @inbounds for i = lo:hi
        j = i
        x = src[i]
        while j > lo
            y = dst[j-1]
            lt(o, x, y) || break
            dst[j] = y
            j -= 1
        end
        dst[j] = x
    end
end

make_scratch2(v::AbstractVector) = (similar(v), Memory{Tuple{Int, Int, typeof(v), typeof(v)}}(undef, Base.top_set_bit(length(v)-1)))
function qs3!(v::AbstractVector, (t,stack) = make_scratch2(v), o::Ordering=Forward)
    stack_size = 0

    lo, hi = firstindex(v), lastindex(v)

    src = v
    dst = t

    @inbounds if hi - lo > THRESHOLD()
        while true

            # src[lo:hi] => dst[lo:hi]

            pivot_index = mod(hash(lo), lo:hi)

            pivot = src[pivot_index]
            src[pivot_index] = src[hi]

            large_values = 0
            for i in lo:hi-1
                x = src[i]
                fx = lt(o, pivot, x)
                dst[(fx ? hi : i) - large_values] = x
                large_values += fx
            end

            new_pivot_index = hi-large_values

            if new_pivot_index-lo < THRESHOLD() && hi-new_pivot_index < THRESHOLD()
                smallsort_to!(v, dst, lo, new_pivot_index-1, o)
                smallsort_to!(v, dst, new_pivot_index+1, hi, o)
                stack_size == 0 && (v[new_pivot_index] = pivot; break)
                lo, hi, src, dst = stack[stack_size]
                stack_size -= 1
            elseif new_pivot_index-lo < THRESHOLD()
                smallsort_to!(v, dst, lo, new_pivot_index-1, o)
                lo = new_pivot_index+1
            elseif hi-new_pivot_index < THRESHOLD()
                smallsort_to!(v, dst, new_pivot_index+1, hi, o)
                hi = new_pivot_index-1
            elseif new_pivot_index-lo < hi-new_pivot_index
                stack[stack_size += 1] = (new_pivot_index+1, hi, src, dst)
                hi = new_pivot_index-1
            else
                stack[stack_size += 1] = (lo, new_pivot_index-1, src, dst)
                lo = new_pivot_index+1
            end
            dst,src = src,dst

            v[new_pivot_index] = pivot
        end
    else
        smallsort_to!(v, v, lo, hi, o)
    end

    v
end