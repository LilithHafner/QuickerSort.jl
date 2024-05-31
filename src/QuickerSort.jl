module QuickerSort

include("insertion_sort.jl")
include("simple_hoare.jl")
include("simple_lomuto.jl")
include("simple_hafner.jl")
include("optimized_hafner.jl")

include("../plots/data.jl")
include("../plots/plot.jl")

function reproduce_figure()
    save_data()
    plot_data()
    savefig("fig.svg")
end

end