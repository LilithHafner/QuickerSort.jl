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
    @time save_comparrison_data()
    plot_comparrison_data()
    savefig("comparrisons.svg")
end

end