function unrolled_merge_expr(target_index, xs, ys, sources)
    if isempty(xs)
        Expr(:block, (:(v[i + $(target_index + i - 1)] = $(ys[i])) for i in eachindex(ys, sources) if ys[i] != sources[i])...)
    elseif isempty(ys)
        Expr(:block, (:(v[i + $(target_index + i - 1)] = $(xs[i])) for i in eachindex(xs, sources) if xs[i] != sources[i])...)
    else
        x, x_tail = xs[1], xs[2:end]
        y, y_tail = ys[1], ys[2:end]
        s, s_tail = sources[1], sources[2:end]

        true_next = unrolled_merge_expr(target_index+1, xs, y_tail, s_tail)
        false_next = unrolled_merge_expr(target_index+1, x_tail, ys, s_tail)

        true_body = y == s ? join_block(true_next) : join_block(:(v[i + $target_index] = $y), true_next)
        false_body = x == s ? join_block(false_next) : join_block(:(v[i + $target_index] = $x), false_next)

        Expr(:if, :(isless($y, $x)), true_body, false_body)
    end
end

function unrolled_mergesort_dfs_exprs(target_index, n)
    x = Ref(0)
    unrolled_mergesort_dfs_exprs(target_index, n, () -> (x[] += 1))
end
function unrolled_mergesort_dfs_exprs(target_index, n, gensym)
    n in (0, 1) && return Expr[]
    n2 = div(n, 2)
    n1 = n - n2
    res = vcat(unrolled_mergesort_dfs_exprs(target_index, n1, gensym), unrolled_mergesort_dfs_exprs(target_index + n1, n2, gensym))
    sym = gensym()
    syms = [Symbol(:x, :_, sym, :_, i) for i in 1:n]
    push!(res, :($(Expr(:tuple, syms...)) = $(Expr(:tuple, (:(v[i + $j]) for j in target_index:target_index+n-1)...))))
    push!(res, unrolled_merge_expr(target_index, syms[1:n1], syms[n1+1:end], syms))
    res
end

function unrolled_mergesort_function_expr(n, target_index=0)
    exprs = unrolled_mergesort_dfs_exprs(target_index, n)
    Expr(:function, :(unrolled_mergesort(v, i=firstindex(v))), Expr(:block,
        :(len = length(v)),
        Expr(:if, :(len < 2), :(return)),
        [Expr(:if, :(len == $i), Expr(:block, unrolled_mergesort_dfs_exprs(target_index, i)..., :(return))) for i in 2:(n-1)]...,
        unrolled_mergesort_dfs_exprs(target_index, n)...,
        :(return),
    ))
end

function create_unrolled_mergesort(n)
    eval(unrolled_mergesort_function_expr(n))
end

function join_block(exprs::Expr...)
    body = []
    for expr in exprs
        if expr.head == :block
            append!(body, expr.args)
        else
            push!(body, expr)
        end
    end
    Expr(:block, body...)
end
