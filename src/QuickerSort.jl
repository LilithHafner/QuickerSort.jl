module QuickerSort

include("insertion_sort.jl")
include("simple_hoare.jl")
include("simple_lomuto.jl")
include("simple_hafner.jl")
include("optimized_hafner.jl")

include("../plots/data.jl")
include("../plots/plot.jl")

function reproduce_figures()
    @time save_runtime_data()
    plot_runtime_data()
    savefig("runtime.svg")
    @time save_count_data()
    plot_count_data()
    savefig("comparrisons.svg")
end

end