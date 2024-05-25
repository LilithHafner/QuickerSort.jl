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

function make_scratch(v::AbstractVector)
    t = similar(v)
    stack_size = max(0, Base.top_set_bit(length(v))-Base.top_set_bit(THRESHOLD()))
    stack = Memory{Tuple{Int, Int, typeof(v), typeof(v), Bool}}(undef, stack_size)
    t, stack
end

function quicker_sort!(v::AbstractVector, (t,stack) = make_scratch(v))
    stack_size = 0

    lo, hi = firstindex(v), lastindex(v)

    src = v
    dst = t
    rev = false

    @inbounds if hi - lo > THRESHOLD()
        while true

            # src[lo:hi] => dst[lo:hi]

            large_values = 0
            lox = lo
            hix = hi
            hi_hi = false

            # pivot_index = rand(lo:hi)
            # pivot = src[pivot_index]
            pivot_a = src[lo]
            pivot_b = src[(lo+hi) >> 1]
            pivot_c = src[hi]
            if isless(pivot_b, pivot_a)
                if isless(pivot_c, pivot_b)
                    pivot_index = (lo+hi) >> 1
                    pivot = pivot_b
                    lox += 1
                    large_values += 1
                    dst[hi] = pivot_a
                    hix -= 1
                elseif isless(pivot_c, pivot_a)
                    pivot_index = hi
                    pivot = pivot_c
                    lox += 1
                    large_values += 1
                    dst[hi] = pivot_a
                else
                    pivot_index = lo
                    pivot = pivot_a
                    hix -= 1
                    hi_hi = true
                end
            else
                if isless(pivot_c, pivot_a)
                    pivot_index = lo
                    pivot = pivot_a
                    hix -= 1
                elseif isless(pivot_c, pivot_b)
                    pivot_index = hi
                    pivot = pivot_c
                    lox += 1
                    dst[lo] = pivot_a
                else
                    pivot_index = (lo+hi) >> 1
                    pivot = pivot_b
                    lox += 1
                    dst[lo] = pivot_a
                    hix -= 1
                    hi_hi = true
                end
            end

            for i in lox:pivot_index-1
                x = src[i]
                fx = rev ? !isless(x, pivot) : isless(pivot, x)
                dst[(fx ? hi : i) - large_values] = x
                large_values += fx
            end
            for i in pivot_index+1:hix
                x = src[i]
                fx = rev ? isless(pivot, x) : !isless(x, pivot)
                dst[(fx ? hi : i-1) - large_values] = x
                large_values += fx
            end

            hix != hi && (dst[hix-large_values+hi_hi] = src[hi])
            large_values += hi_hi

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

struct Div10
    n::Int
end
Base.isless(a::Div10, b::Div10) = a.n÷10 < b.n÷10
function test()
    for len in 1:1000
        for _ in 1:10
            v = rand(len)
            quicker_sort!(copy(v)) == sort(v) || error("Correctness $len")
        end

        v2 = Div10.(rand(Int, len))
        quicker_sort!(copy(v2)) == sort(v2) || error("Stability $len")
    end
end

struct Count
    n::Int
    counter::Base.RefValue{Int}
end
Base.isless(a::Count, b::Count) = (a.counter[] += 1; a.n < b.n)
function count_comparisons(n)
    counter = Ref(0)
    x = rand(Int, n)
    quicker_sort!(Count.(x, Ref(counter)))
    counter[]
end
count_comparisons(n, m) = [count_comparisons(n) for _ in 1:m]
function min_count(n)
    Float64(log2(factorial(big(n))))
end
