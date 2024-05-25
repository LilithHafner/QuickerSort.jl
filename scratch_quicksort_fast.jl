THRESHOLD() = 20

"Use insertion sort to sort `src[lo:hi]` into `dst[lo:hi]`. Stable if rev=false, otherwise reverse-stable."
function smallsort_to!(dst::AbstractVector, src::AbstractVector, lo::Int, hi::Int, rev::Bool)
    @inbounds for i = lo:hi
        j = i
        x = src[i]
        while j > lo
            y = dst[j-1]
            (rev ? !isless(y, x) : isless(x, y)) || break
            dst[j] = y
            j -= 1
        end
        dst[j] = x
    end
end

make_scratch(v::AbstractVector) = similar(v), Memory{Tuple{Int, Int, typeof(v), typeof(v), Bool}}(undef, max(0, Base.top_set_bit(length(v))-Base.top_set_bit(THRESHOLD())))
function quicker_sort!(v::AbstractVector, (t,stack) = make_scratch(v))
    stack_size = 0

    lo, hi = firstindex(v), lastindex(v)

    src = v
    dst = t
    rev = false

    @inbounds if hi - lo > THRESHOLD()
        while true

            # src[lo:hi] => dst[lo:hi]

            pivot_index = rand(lo:hi)

            pivot = src[pivot_index]

            large_values = 0

            for i in lo:pivot_index-1
                x = src[i]
                fx = rev ? !isless(x, pivot) : isless(pivot, x)
                dst[(fx ? hi : i) - large_values] = x
                large_values += fx
            end
            for i in pivot_index+1:hi
                x = src[i]
                fx = rev ? isless(pivot, x) : !isless(x, pivot)
                dst[(fx ? hi : i-1) - large_values] = x
                large_values += fx
            end

            new_pivot_index = hi-large_values

            if new_pivot_index-lo < THRESHOLD() && hi-new_pivot_index < THRESHOLD()
                smallsort_to!(v, dst, lo, new_pivot_index-1, rev)
                smallsort_to!(v, dst, new_pivot_index+1, hi, !rev)
                stack_size == 0 && (v[new_pivot_index] = pivot; break)
                lo, hi, src, dst, rev = stack[stack_size]
                stack_size -= 1
            elseif new_pivot_index-lo < THRESHOLD()
                smallsort_to!(v, dst, lo, new_pivot_index-1, rev)
                lo = new_pivot_index+1
                rev = !rev
            elseif hi-new_pivot_index < THRESHOLD()
                smallsort_to!(v, dst, new_pivot_index+1, hi, !rev)
                hi = new_pivot_index-1
            elseif new_pivot_index-lo < hi-new_pivot_index
                stack[stack_size += 1] = (new_pivot_index+1, hi, src, dst, !rev)
                hi = new_pivot_index-1
            else
                stack[stack_size += 1] = (lo, new_pivot_index-1, src, dst, rev)
                lo = new_pivot_index+1
                rev = !rev
            end
            dst,src = src,dst

            v[new_pivot_index] = pivot
        end
    else
        smallsort_to!(v, v, lo, hi, false)
    end

    v
end
