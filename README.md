# QuickerSort

[![Build Status](https://github.com/LilithHafner/QuickerSort.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/QuickerSort.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a demonstration package to highlight the partitioning scheme I developed for use in Julia's default non-radixable sorting algorithm.

The most effective way to utilize the fruits of this research in deployment is to use the Julia default sorting algorithms. However, for academics or developers seeking to understand, test, and further improve these algorithms, this is a package worth looking at.

## Usage example

```julia
using Pkg
Pkg.add(url="https://github.com/LilithHafner/QuickerSort.jl")
using QuickerSort
data = rand(1000)
QuickerSort.hafner_quicksort!(data)
@assert issorted(data)
QuickerSort.reproduce_figures() # reproduce figures from the paper
readdir(".") # The figures should be listed here
```

## How to use this repository

The paper and associated information lives in the `paper` directory. The reference
implementations live in the `src` directory, with tests in the `test` directory. Folks
wishing to build upon, port, or copy this code should probably read `src/simple_hafner.jl`
and then `src/optimized_hafner.jl`.
